"use strict";
/**
 * 文件删除监听器
 *
 * 职责：监听文件删除事件，清除对应的诊断信息
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
exports.registerDeleteListener = registerDeleteListener;
const vscode = __importStar(require("vscode"));
const file_checker_1 = require("../../shared/file-checker");
const log_1 = require("../../utils/log");
/**
 * 注册文件删除监听器
 *
 * @param diagnosticCollection VSCode 诊断集合
 */
function registerDeleteListener(diagnosticCollection) {
    log_1.logger.info("Registering file delete listener");
    return vscode.workspace.onDidDeleteFiles((event) => {
        for (const uri of event.files) {
            // 跳过特殊文件
            if ((0, file_checker_1.shouldSkipUri)(uri)) {
                log_1.logger.debug(`Skipping delete listener for: ${uri.toString()} (special file)`);
                continue;
            }
            // 清除该文件的诊断信息
            diagnosticCollection.delete(uri);
            log_1.logger.debug(`Diagnostics cleared for deleted file: ${uri.toString()}`);
        }
    });
}
//# sourceMappingURL=delete-listener.js.map