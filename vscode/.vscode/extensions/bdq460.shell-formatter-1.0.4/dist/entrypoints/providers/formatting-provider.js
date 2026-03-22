"use strict";
/**
 * 文档格式化提供者
 *
 * 职责：注册 VSCode 格式化提供者，处理格式化请求
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
exports.registerFormattingProvider = registerFormattingProvider;
const vscode = __importStar(require("vscode"));
const format_document_1 = require("../../application/usecases/format-document");
const config_1 = require("../../config");
const i18n_1 = require("../../i18n");
const document_1 = require("../../shared/converters/document");
const file_checker_1 = require("../../shared/file-checker");
const log_1 = require("../../utils/log");
/**
 * 注册文档格式化提供者
 */
function registerFormattingProvider() {
    log_1.logger.info("Registering document range formatting provider");
    return vscode.languages.registerDocumentRangeFormattingEditProvider(config_1.PackageInfo.languageId, {
        async provideDocumentRangeFormattingEdits(document, range, _options, token) {
            // 跳过特殊文件
            if ((0, file_checker_1.shouldSkipFile)(document)) {
                log_1.logger.info(`Skipping range formatting for: ${document.fileName} (special file)`);
                vscode.window.showInformationMessage((0, i18n_1.t)("messages.unsupportedFileType"));
                return [];
            }
            log_1.logger.info(`Document range formatting triggered! Document: ${document.fileName}, range: [${range.start.line}, ${range.start.character}] - [${range.end.line}, ${range.end.character}]`);
            log_1.logger.info(`Note: Shell script formatting requires full document context, will format entire document`);
            // 转换为领域文档并执行格式化
            const domainDocument = (0, document_1.toDomainDocument)(document);
            const textEdits = await (0, format_document_1.formatDocument)(domainDocument, {
                token: {
                    isCancellationRequested: token.isCancellationRequested,
                    onCancellationRequested: (callback) => {
                        const disposable = token.onCancellationRequested(callback);
                        return {
                            dispose: () => disposable.dispose(),
                        };
                    },
                },
            });
            // 将领域 TextEdit 转换为 VSCode TextEdit
            return textEdits.map((edit) => new vscode.TextEdit(new vscode.Range(edit.range.start.line, edit.range.start.character, edit.range.end.line, edit.range.end.character), edit.newText));
        },
    });
}
//# sourceMappingURL=formatting-provider.js.map