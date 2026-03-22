"use strict";
/**
 * Code Actions 提供者
 *
 * 职责：注册 VSCode Code Actions 提供者，处理快速修复
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
exports.ShellFormatCodeActionProvider = void 0;
exports.registerCodeActionsProvider = registerCodeActionsProvider;
const vscode = __importStar(require("vscode"));
const config_1 = require("../../config");
const i18n_1 = require("../../i18n");
const file_checker_1 = require("../../shared/file-checker");
const performance_metrics_1 = require("../../shared/performance-metrics");
const log_1 = require("../../utils/log");
const monitor_1 = require("../../utils/performance/monitor");
/**
 * ShellFormat Code Action 提供者
 *
 * @param diagnosticCollection VSCode 诊断集合
 */
class ShellFormatCodeActionProvider {
    constructor(diagnosticCollection) {
        this.diagnosticCollection = diagnosticCollection;
    }
    /**
     * 提供 Code Actions
     * provideCodeActions 的调用机制
     * 触发时机
     * VS Code 会在以下情况调用 provideCodeActions：
     * 1. 右键点击代码 → 显示上下文菜单
     * 2. 点击灯泡图标 💡 → 显示快速修复选项
     * 3. 按 Cmd+. / Ctrl+. → 显示快速修复面板
     * 4. 保存文件时（如果配置了 editor.codeActionsOnSave）
     * 5. 编辑器焦点变化时（VS Code 可能会预先获取）
     */
    provideCodeActions(document, range, context, _token) {
        const timer = (0, monitor_1.startTimer)(performance_metrics_1.PERFORMANCE_METRICS.PROVIDER_CODE_ACTIONS_DURATION);
        log_1.logger.info(`Code Actions requested for ${document.fileName}`);
        // 跳过特殊文件
        if ((0, file_checker_1.shouldSkipFile)(document)) {
            log_1.logger.debug(`Skipping code actions for: ${document.fileName} (special file)`);
            vscode.window.showInformationMessage((0, i18n_1.t)("messages.unsupportedFileType"));
            timer.stop();
            return [];
        }
        const actions = [];
        // 调试信息：详细上下文
        log_1.logger.debug(`Trigger kind: ${context.triggerKind}`);
        log_1.logger.debug(`Requested range: [${range.start.line}, ${range.start.character}] - [${range.end.line}, ${range.end.character}]`);
        if (context.only) {
            log_1.logger.debug(`Code action kind filter: ${context.only.value}`);
        }
        // 从 DiagnosticCollection 获取当前文档的所有诊断
        const documentDiagnostics = this.diagnosticCollection.get(document.uri) || [];
        log_1.logger.debug(`Document has ${documentDiagnostics.length} total diagnostics`);
        // 检查是否有来自本扩展的诊断
        const matchingDiagnostics = documentDiagnostics.filter((d) => d.source === config_1.PackageInfo.diagnosticSource);
        // 如果没有来自本扩展的诊断问题，则不提供任何操作
        if (matchingDiagnostics.length === 0) {
            log_1.logger.debug("No matching diagnostics from this extension");
            timer.stop();
            return actions;
        }
        log_1.logger.info(`Found ${matchingDiagnostics.length} diagnostics from this extension`);
        // 策略：
        // - "Fix all problems with shell-format" 支持 SourceFixAll（"Fix All" 命令）
        // - "Fix this issue with shell-format" 只在 context.diagnostics 有诊断时显示（光标在错误位置）
        // 如果 context.only 是 SourceFixAll，则返回 FixAll action
        if (context.only &&
            context.only.contains(vscode.CodeActionKind.SourceFixAll)) {
            log_1.logger.debug(`SourceFixAll requested, providing Fix All action`);
            const fixAllAction = new vscode.CodeAction(config_1.PackageInfo.codeActionFixAllTitle, vscode.CodeActionKind.SourceFixAll);
            fixAllAction.command = {
                title: config_1.PackageInfo.codeActionFixAllTitle,
                command: config_1.PackageInfo.commandFixAllProblems,
                arguments: [document.uri],
            };
            actions.push(fixAllAction);
            timer.stop();
            log_1.logger.info(`Provided SourceFixAll action for ${document.fileName}`);
            return actions;
        }
        // 如果 context.diagnostics 有来自本扩展的诊断，创建 "Fix this issue"
        if (context.diagnostics && context.diagnostics.length > 0) {
            // 检查 context.diagnostics 是否有来自本扩展的诊断
            const contextMatchingDiagnostics = context.diagnostics.filter((d) => d.source === config_1.PackageInfo.diagnosticSource);
            if (contextMatchingDiagnostics.length > 0) {
                log_1.logger.debug(`Providing QuickFix for ${contextMatchingDiagnostics.length} diagnostics`);
                // 只为第一个匹配的诊断创建 QuickFix，避免重复
                const diagnostic = contextMatchingDiagnostics[0];
                const fixThisAction = new vscode.CodeAction(config_1.PackageInfo.codeActionQuickFixTitle, vscode.CodeActionKind.QuickFix);
                // 关联当前诊断问题
                fixThisAction.diagnostics = [diagnostic];
                fixThisAction.isPreferred = true;
                fixThisAction.command = {
                    title: config_1.PackageInfo.codeActionQuickFixTitle,
                    command: config_1.PackageInfo.commandFixAllProblems,
                    arguments: [document.uri],
                };
                actions.push(fixThisAction);
            }
            else {
                log_1.logger.debug("Context has diagnostics but none from this extension");
            }
        }
        // 为整个文档提供独立的 QuickFix: "Fix all problems with shell-format"
        // 不关联任何特定诊断，这样会在右键菜单中单独显示
        const fixAllAction = new vscode.CodeAction(config_1.PackageInfo.codeActionFixAllTitle, vscode.CodeActionKind.QuickFix);
        fixAllAction.command = {
            title: config_1.PackageInfo.codeActionFixAllTitle,
            command: config_1.PackageInfo.commandFixAllProblems,
            arguments: [document.uri],
        };
        actions.push(fixAllAction);
        timer.stop();
        log_1.logger.info(`Provided ${actions.length} code actions for ${document.fileName}`);
        return actions;
    }
}
exports.ShellFormatCodeActionProvider = ShellFormatCodeActionProvider;
/**
 * 注册 Code Actions 提供者
 *
 * @param diagnosticCollection VSCode 诊断集合
 */
function registerCodeActionsProvider(diagnosticCollection) {
    // registerCodeActionsProvider与CodeActionsProvider工作机制参考文档:
    // - 官方文档:https://code.visualstudio.com/api/references/vscode-api#CodeActionKind
    // - 本地文档:doc/vscode/extension-api.md
    log_1.logger.info("Registering code actions provider!");
    return vscode.languages.registerCodeActionsProvider(config_1.PackageInfo.languageId, new ShellFormatCodeActionProvider(diagnosticCollection), {
        providedCodeActionKinds: [
            vscode.CodeActionKind.QuickFix,
            vscode.CodeActionKind.SourceFixAll.append(config_1.PackageInfo.extensionName),
        ],
    });
}
//# sourceMappingURL=code-actions-provider.js.map