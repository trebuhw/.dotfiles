"use strict";
/**
 * 格式化命令模块
 * 提供格式化文档命令的注册
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
exports.registerFormatDocumentCommand = registerFormatDocumentCommand;
const vscode = __importStar(require("vscode"));
const config_1 = require("../../config");
const i18n_1 = require("../../i18n");
const file_checker_1 = require("../../shared/file-checker");
const log_1 = require("../../utils/log");
/**
 * 注册格式化文档命令
 */
function registerFormatDocumentCommand() {
    log_1.logger.info("Registering format document command");
    return vscode.commands.registerCommand(config_1.PackageInfo.commandFormatDocument, async () => {
        log_1.logger.info("Format document command triggered");
        const activeEditor = vscode.window.activeTextEditor;
        if (!activeEditor) {
            vscode.window.showWarningMessage((0, i18n_1.t)("messages.noActiveDocument"));
            return;
        }
        // 检查文件是否需要跳过
        if ((0, file_checker_1.shouldSkipFile)(activeEditor.document)) {
            log_1.logger.info(`Skipping format document for: ${activeEditor.document.fileName}`);
            vscode.window.showInformationMessage((0, i18n_1.t)("messages.unsupportedFileType"));
            return;
        }
        await vscode.commands.executeCommand("editor.action.formatDocument", activeEditor.document.uri);
    });
}
//# sourceMappingURL=format-command.js.map