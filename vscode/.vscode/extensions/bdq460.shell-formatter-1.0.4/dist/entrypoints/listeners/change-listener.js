"use strict";
/**
 * 文档变更监听器
 *
 * 职责：监听文档内容变更事件，触发防抖诊断
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
exports.registerChangeListener = registerChangeListener;
const vscode = __importStar(require("vscode"));
const diagnose_document_1 = require("../../application/usecases/diagnose-document");
const diagnostic_1 = require("../../shared/converters/diagnostic");
const document_1 = require("../../shared/converters/document");
const file_checker_1 = require("../../shared/file-checker");
const log_1 = require("../../utils/log");
/**
 * 注册文档变更监听器
 *
 * @param diagnosticCollection VSCode 诊断集合
 * @param debounceManager 防抖管理器
 */
function registerChangeListener(diagnosticCollection, debounceManager) {
    log_1.logger.info("Registering document change listener");
    return vscode.workspace.onDidChangeTextDocument((event) => {
        // 跳过特殊文件
        if ((0, file_checker_1.shouldSkipFile)(event.document)) {
            log_1.logger.debug(`Skipping change diagnosis for: ${event.document.fileName} (special file)`);
            return;
        }
        log_1.logger.debug(`Document change triggered debounce for: ${event.document.fileName}`);
        const uri = event.document.uri.toString();
        const fileUri = event.document.uri;
        debounceManager.debounce(uri, async () => {
            // 重新诊断以获取最新状态
            try {
                // 重新获取最新文档，避免使用过时的引用
                const textDocument = vscode.workspace.textDocuments.find(doc => doc.uri.toString() === uri);
                if (!textDocument) {
                    log_1.logger.debug(`Document ${uri} not found in workspace, skipping diagnosis`);
                    return;
                }
                const domainDocument = (0, document_1.toDomainDocument)(textDocument);
                const diagnostics = await (0, diagnose_document_1.diagnoseDocument)(domainDocument);
                const vscodeDiagnostics = (0, diagnostic_1.fromDomainDiagnostics)(diagnostics);
                // 强制更新诊断集合
                diagnosticCollection.set(fileUri, vscodeDiagnostics);
                log_1.logger.debug(`Updated diagnostics for changed file: ${vscodeDiagnostics.length} diagnostics`);
            }
            catch (error) {
                log_1.logger.error(`Error diagnosing changed document ${event.document.fileName}: ${String(error)}`);
            }
        }, 300);
    });
}
//# sourceMappingURL=change-listener.js.map