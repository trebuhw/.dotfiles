"use strict";
/**
 * 文档关闭监听器
 *
 * 职责：监听文档关闭事件，清除防抖定时器和诊断信息
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
exports.registerCloseListener = registerCloseListener;
const vscode = __importStar(require("vscode"));
const file_checker_1 = require("../../shared/file-checker");
const log_1 = require("../../utils/log");
/**
 * 注册文档关闭监听器
 *
 * @param diagnosticCollection VSCode 诊断集合
 * @param debounceManager 防抖管理器
 */
function registerCloseListener(diagnosticCollection, debounceManager) {
    log_1.logger.info("Registering document close listener");
    return vscode.workspace.onDidCloseTextDocument((document) => {
        // 跳过特殊文件
        if ((0, file_checker_1.shouldSkipFile)(document)) {
            log_1.logger.debug(`Skipping close diagnosis for: ${document.fileName} (special file)`);
            return;
        }
        const uri = document.uri.toString();
        // 取消防抖定时器，避免延迟诊断
        debounceManager.cancel(uri);
        // 清除该文件的诊断信息
        diagnosticCollection.delete(document.uri);
        log_1.logger.debug(`Debounce timer and diagnostics cleared for closed document: ${document.fileName}`);
    });
}
//# sourceMappingURL=close-listener.js.map