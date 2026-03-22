"use strict";
/**
 * 修复命令模块
 * 提供"修复所有问题"命令的实现
 *
 * 核心流程：
 * 1. 查找目标文档（从问题面板的 URI 或当前活动编辑器）
 * 2. 调用格式化工具生成修复操作
 * 3. 应用修复操作到文档
 * 4. 等待文档更新完成
 * 5. 重新诊断以获取最新的问题列表
 * 6. 更新诊断集合，确保问题面板显示最新状态
 * 7. 显示修复结果消息
 *
 * 关键设计：
 * - 使用 WorkspaceEdit 批量应用修复操作，确保原子性
 * - 等待 100ms 让文档更新完成，避免诊断时读到旧内容
 * - 修复后立即重新诊断，确保问题面板与实际文件状态同步
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerFixAllCommand = registerFixAllCommand;
const vscode = __importStar(require("vscode"));
const diagnose_document_1 = require("../../application/usecases/diagnose-document");
const format_document_1 = require("../../application/usecases/format-document");
const config_1 = require("../../config");
const i18n_1 = require("../../i18n");
const diagnostic_1 = require("../../shared/converters/diagnostic");
const document_1 = require("../../shared/converters/document");
const file_checker_1 = require("../../shared/file-checker");
const log_1 = require("../../utils/log");
/**
 * 根据传入的 URI 查找文档
 *
 * 支持两种调用方式：
 * 1. 从问题面板点击修复时，会传入文档 URI
 * 2. 从命令面板执行命令时，没有 URI，使用当前活动编辑器
 *
 * 核心逻辑：
 * - 如果有 URI，从所有打开的文档中查找匹配的文档
 * - 如果没有 URI，使用当前活动编辑器的文档
 * - 如果都找不到，返回 undefined
 *
 * @param uri 可选的文档 URI
 * @returns 文档对象，如果未找到则返回 undefined
 */
function findDocument(uri) {
    if (uri) {
        // 场景 1: 从问题面板的修复命令调用
        // 问题面板中的每个问题都绑定了文档 URI
        return vscode.workspace.textDocuments.find((doc) => doc.uri.toString() === uri.toString());
    }
    else if (vscode.window.activeTextEditor) {
        // 场景 2: 从命令面板调用（Ctrl+Shift+P -> Fix All Problems）
        // 使用当前活动编辑器的文档
        return vscode.window.activeTextEditor.document;
    }
    return undefined;
}
/**
 * 创建 WorkspaceEdit 对象并应用修复操作
 *
 * 核心逻辑：
 * 1. 创建 WorkspaceEdit 对象，用于批量编辑操作
 * 2. 将所有文本编辑操作添加到 WorkspaceEdit
 * 3. 应用 WorkspaceEdit，这是一个原子操作，要么全部成功，要么全部失败
 *
 * WorkspaceEdit 的优势：
 * - 支持多个文档的同时编辑
 * - 支持撤销/重做操作（作为单一操作）
 * - 自动处理文件变更通知
 *
 * @param document 文档对象
 * @param edits 编辑操作数组
 * @returns 是否成功应用编辑操作
 */
async function applyEdits(document, edits) {
    // 创建 WorkspaceEdit 对象
    const edit = new vscode.WorkspaceEdit();
    // 将所有编辑操作添加到 WorkspaceEdit
    // 每个 TextEdit 指定了替换的范围和新文本
    for (const textEdit of edits) {
        edit.replace(document.uri, textEdit.range, textEdit.newText);
    }
    // 应用编辑操作
    // 这是一个异步操作，VSCode 会处理所有的文本替换
    return await vscode.workspace.applyEdit(edit);
}
/**
 * 等待文档更新并获取最新的文档对象
 *
 * 核心逻辑：
 * 1. 等待 100ms，让 VSCode 完成文档的更新
 * 2. 从 workspace.textDocuments 中重新获取文档对象
 * 3. 返回最新的文档对象，确保内容是最新的
 *
 * 为什么需要等待：
 * - applyEdit 是异步的，文档更新可能没有立即完成
 * - 如果立即诊断，可能读到旧的内容
 * - 100ms 的等待时间是基于经验值，大多数情况下足够
 *
 * @param originalUri 原始文档 URI
 * @returns 更新后的文档对象，如果未找到则返回 undefined
 */
async function getUpdatedDocument(originalUri) {
    // 等待文档更新完成
    // 100ms 是一个经验值，大多数情况下足够让 VSCode 完成文档更新
    await new Promise((resolve) => setTimeout(resolve, 100));
    // 获取更新后的文档（确保使用最新的文档内容）
    // workspace.textDocuments 包含所有在编辑器中打开的文档
    return vscode.workspace.textDocuments.find((doc) => doc.uri.toString() === originalUri.toString());
}
/**
 * 更新诊断信息
 *
 * 核心逻辑：
 * 1. 调用诊断引擎对文档进行诊断
 * 2. 将诊断结果更新到诊断集合中
 * 3. 返回剩余的诊断数量，用于显示结果消息
 *
 * 诊断更新策略：
 * - 使用 document.uri 作为键，更新或创建诊断
 * - 如果 diagnostics 为空数组，会清除之前的所有诊断
 * - 这确保问题面板显示的是最新的问题列表
 *
 * @param document 文档对象
 * @param diagnosticCollection 诊断集合
 * @returns 更新后的诊断数量
 */
async function updateDiagnostics(document, diagnosticCollection) {
    // 对文档进行诊断
    // diagnoseDocument 会调用所有的诊断插件（shfmt、shellcheck）
    const domainDocument = (0, document_1.toDomainDocument)(document);
    const diagnostics = await (0, diagnose_document_1.diagnoseDocument)(domainDocument);
    const vscodeDiagnostics = (0, diagnostic_1.fromDomainDiagnostics)(diagnostics);
    // 更新诊断集合
    // VSCode 会自动更新问题面板，显示最新的诊断信息
    diagnosticCollection.set(document.uri, vscodeDiagnostics);
    // 记录日志并返回诊断数量
    log_1.logger.info(`Re-diagnosed after fix: ${vscodeDiagnostics.length} diagnostics remain`);
    return vscodeDiagnostics.length;
}
/**
 * 显示修复结果消息
 *
 * 核心逻辑：
 * - 如果所有问题都已修复，显示成功消息（绿色提示）
 * - 如果仍有问题，显示警告消息（黄色提示），告知剩余问题数量
 *
 * 消息类型选择：
 * - showInformationMessage: 用于成功场景，绿色图标
 * - showWarningMessage: 用于部分成功场景，黄色图标，提醒用户检查
 *
 * @param appliedFixCount 应用的修复数量
 * @param remainingDiagCount 剩余的诊断数量
 */
function showResultMessage(appliedFixCount, remainingDiagCount) {
    if (remainingDiagCount === 0) {
        // 所有问题都已修复
        vscode.window.showInformationMessage((0, i18n_1.t)("messages.allProblemsFixed"));
    }
    else {
        // 部分修复成功，但仍有问题
        vscode.window.showWarningMessage((0, i18n_1.t)("messages.partialFixSuccess", {
            count: appliedFixCount,
            remaining: remainingDiagCount
        }));
    }
}
/**
 * 处理有修复操作的情况
 *
 * 核心逻辑：
 * 1. 应用修复操作到文档
 * 2. 等待文档更新完成
 * 3. 重新诊断以获取最新状态
 * 4. 更新诊断集合
 * 5. 显示修复结果
 *
 * 完整流程说明：
 * - applyEdits: 将修复操作应用到文档
 * - getUpdatedDocument: 等待并获取更新后的文档
 * - updateDiagnostics: 重新诊断并更新诊断集合
 * - showResultMessage: 显示修复结果给用户
 *
 * 为什么需要这个函数：
 * - 分离有修复和无修复的逻辑，提高代码可读性
 * - 将完整的修复流程封装在一个函数中
 *
 * @param document 文档对象
 * @param edits 编辑操作数组
 * @param diagnosticCollection 诊断集合
 */
async function handleFixesApplied(document, edits, diagnosticCollection) {
    log_1.logger.info(`Applying ${edits.length} formatting fix(es)`);
    // 步骤 1: 应用修复操作
    const editSuccess = await applyEdits(document, edits);
    if (!editSuccess) {
        log_1.logger.error("Failed to apply formatting edits");
        return;
    }
    // 步骤 2: 等待文档更新并获取最新文档
    const updatedDocument = await getUpdatedDocument(document.uri);
    if (!updatedDocument) {
        log_1.logger.error("Failed to get updated document after fix");
        return;
    }
    // 步骤 3: 重新诊断并更新诊断集合
    const remainingDiagCount = await updateDiagnostics(updatedDocument, diagnosticCollection);
    // 步骤 4: 显示修复结果
    showResultMessage(edits.length, remainingDiagCount);
}
/**
 * 处理无修复操作的情况
 *
 * 核心逻辑：
 * 1. 直接对文档进行诊断
 * 2. 更新诊断集合
 * 3. 根据诊断结果显示相应消息
 *
 * 可能的场景：
 * - 文档本身没有问题，不需要修复
 * - 文档有问题，但格式化工具无法自动修复（如语法错误）
 * - 格式化工具返回空数组，表示无需修改
 *
 * 为什么需要这个函数：
 * - 与有修复的情况分离，逻辑更清晰
 * - 提供更详细的诊断信息
 *
 * @param document 文档对象
 * @param diagnosticCollection 诊断集合
 */
async function handleNoFixes(document, diagnosticCollection) {
    log_1.logger.info("No formatting fixes return.");
    // 对文档进行诊断
    // 即使没有修复操作，也需要重新诊断，因为诊断可能已经过期
    const domainDocument = (0, document_1.toDomainDocument)(document);
    const diagnostics = await (0, diagnose_document_1.diagnoseDocument)(domainDocument);
    const vscodeDiagnostics = (0, diagnostic_1.fromDomainDiagnostics)(diagnostics);
    // 更新诊断集合
    diagnosticCollection.set(document.uri, vscodeDiagnostics);
    if (vscodeDiagnostics.length > 0) {
        // 有诊断问题，但无法通过格式化修复
        log_1.logger.info("No formatting fixes needed, but diagnostics found.");
        vscode.window.showWarningMessage((0, i18n_1.t)("messages.formattingFailed"));
    }
    else {
        // 没有任何问题
        log_1.logger.info("No formatting fixes needed.");
    }
}
/**
 * 注册修复所有问题命令
 *
 * 命令入口点，负责处理用户触发的修复命令
 *
 * 触发方式：
 * 1. 点击问题面板中的"Fix all problems with shell-formatter"链接
 * 2. 在编辑器中右键 -> Source Actions -> Fix All
 * 3. 通过命令面板 (Ctrl+Shift+P) 搜索 "shell-formatter: Fix all problems"
 *
 * 完整流程：
 * 1. 查找目标文档（从 URI 或活动编辑器）
 * 2. 调用格式化工具生成修复操作
 * 3. 如果有修复操作，调用 handleFixesApplied
 * 4. 如果没有修复操作，调用 handleNoFixes
 *
 * @param diagnosticCollection VSCode 诊断集合，用于更新诊断信息
 * @returns 可释放的资源对象，VSCode 在扩展停用时自动清理
 */
function registerFixAllCommand(diagnosticCollection) {
    log_1.logger.info("Registering fix all problems command");
    return vscode.commands.registerCommand(config_1.PackageInfo.commandFixAllProblems, async (uri) => {
        // 记录命令触发
        log_1.logger.info(`Start fix all problems! URI: ${uri?.toString() || "N/A"}`);
        // 步骤 1: 查找目标文档
        const document = findDocument(uri);
        if (!document) {
            log_1.logger.warn(`No document found for fix all problems command. uri: ${uri?.toString() || "N/A"}`);
            return;
        }
        log_1.logger.info(`Start fix all problems for: ${document.fileName} `);
        // 步骤 2: 检查文件是否需要跳过
        if ((0, file_checker_1.shouldSkipFile)(document)) {
            log_1.logger.info(`Skipping fix all problems for: ${document.fileName} `);
            vscode.window.showInformationMessage((0, i18n_1.t)("messages.unsupportedFileType"));
            return;
        }
        // 步骤 3: 生成修复操作
        // formatDocument 会调用 shfmt 格式化工具
        // 使用 content 模式，确保修复基于当前编辑器中的内容，与诊断保持一致
        log_1.logger.info("Generating fixes by invoking format document");
        const domainDocument = (0, document_1.toDomainDocument)(document);
        const textEdits = await (0, format_document_1.formatDocument)(domainDocument);
        // 将领域 TextEdit 转换为 VSCode TextEdit
        const edits = textEdits.map((edit) => new vscode.TextEdit(new vscode.Range(edit.range.start.line, edit.range.start.character, edit.range.end.line, edit.range.end.character), edit.newText));
        // 步骤 4: 根据修复数量处理不同情况
        if (edits.length > 0) {
            // 有修复操作：应用修复并更新诊断
            await handleFixesApplied(document, edits, diagnosticCollection);
        }
        else {
            // 无修复操作：直接诊断并更新
            await handleNoFixes(document, diagnosticCollection);
        }
    });
}
//# sourceMappingURL=fix-command.js.map