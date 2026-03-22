"use strict";
/**
 * 文档保存监听器
 *
 * 职责：监听文档保存事件，触发诊断
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
exports.registerSaveListener = registerSaveListener;
const vscode = __importStar(require("vscode"));
const diagnose_document_1 = require("../../application/usecases/diagnose-document");
const diagnostic_1 = require("../../shared/converters/diagnostic");
const document_1 = require("../../shared/converters/document");
const file_checker_1 = require("../../shared/file-checker");
const performance_metrics_1 = require("../../shared/performance-metrics");
const log_1 = require("../../utils/log");
const monitor_1 = require("../../utils/performance/monitor");
/**
 * 注册文档保存监听器
 *
 * @param diagnosticCollection VSCode 诊断集合
 * @param debounceManager 防抖管理器
 */
function registerSaveListener(diagnosticCollection, debounceManager) {
    log_1.logger.info("Registering document save listener");
    return vscode.workspace.onDidSaveTextDocument(async (document) => {
        // 跳过特殊文件
        if ((0, file_checker_1.shouldSkipFile)(document)) {
            log_1.logger.debug(`Skipping save diagnosis for: ${document.fileName} (special file)`);
            return;
        }
        log_1.logger.info(`Document saved: ${document.fileName}`);
        // 清除该文档的防抖定时器，避免被后续的防抖诊断覆盖
        const uri = document.uri.toString();
        debounceManager.cancel(uri);
        // 重新诊断以获取最新状态
        try {
            const timer = (0, monitor_1.startTimer)(performance_metrics_1.PERFORMANCE_METRICS.DOCUMENT_SAVE_DIAGNOSIS_DURATION);
            const domainDocument = (0, document_1.toDomainDocument)(document);
            const diagnostics = await (0, diagnose_document_1.diagnoseDocument)(domainDocument);
            const vscodeDiagnostics = (0, diagnostic_1.fromDomainDiagnostics)(diagnostics);
            timer.stop();
            // 强制更新诊断集合，清除任何旧的诊断信息
            diagnosticCollection.set(document.uri, vscodeDiagnostics);
            log_1.logger.debug(`Updated diagnostics for saved file: ${vscodeDiagnostics.length} diagnostics`);
        }
        catch (error) {
            log_1.logger.error(`Error diagnosing saved document ${document.fileName}: ${String(error)}`);
        }
    });
}
//# sourceMappingURL=save-listener.js.map