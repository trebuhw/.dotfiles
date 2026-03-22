"use strict";
/**
 * 文档打开监听器
 *
 * 职责：监听文档打开事件，触发初始诊断
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
exports.registerOpenListener = registerOpenListener;
const vscode = __importStar(require("vscode"));
const diagnose_document_1 = require("../../application/usecases/diagnose-document");
const diagnostic_1 = require("../../shared/converters/diagnostic");
const document_1 = require("../../shared/converters/document");
const file_checker_1 = require("../../shared/file-checker");
const log_1 = require("../../utils/log");
/**
 * 注册文档打开监听器
 *
 * @param diagnosticCollection VSCode 诊断集合
 */
function registerOpenListener(diagnosticCollection) {
    log_1.logger.info("Registering document open listener");
    return vscode.workspace.onDidOpenTextDocument(async (document) => {
        // 跳过特殊文件
        if ((0, file_checker_1.shouldSkipFile)(document)) {
            log_1.logger.debug(`Skipping open diagnosis for: ${document.fileName} (special file)`);
            return;
        }
        // 诊断文档并设置诊断信息
        try {
            const domainDocument = (0, document_1.toDomainDocument)(document);
            const diagnostics = await (0, diagnose_document_1.diagnoseDocument)(domainDocument);
            const vscodeDiagnostics = (0, diagnostic_1.fromDomainDiagnostics)(diagnostics);
            diagnosticCollection.set(document.uri, vscodeDiagnostics);
            log_1.logger.debug(`Initial diagnostics for opened file: ${vscodeDiagnostics.length} diagnostics`);
        }
        catch (error) {
            log_1.logger.error(`Error diagnosing opened document ${document.fileName}: ${String(error)}`);
        }
    });
}
//# sourceMappingURL=open-listener.js.map