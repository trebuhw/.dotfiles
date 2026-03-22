"use strict";
/**
 * 诊断转换器
 *
 * 职责：
 * - 将工具结果转换为 VSCode Diagnostic
 * - 统一处理诊断的优先级和严重级别
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
exports.fromDomainDiagnostics = fromDomainDiagnostics;
const vscode = __importStar(require("vscode"));
const package_info_1 = require("../../config/package-info");
/**
 * 将领域诊断转换为 VSCode 诊断
 * @param diagnostics 领域诊断数组
 * @returns VSCode 诊断数组
 */
function fromDomainDiagnostics(diagnostics) {
    return diagnostics.map((d) => {
        const range = new vscode.Range(d.range.start.line, d.range.start.character, d.range.end.line, d.range.end.character);
        const diagnostic = new vscode.Diagnostic(range, d.message, d.severity);
        // diagnostic.source = d.source;
        // 统一设置来源为扩展名称
        diagnostic.source = package_info_1.PackageInfo.diagnosticSource;
        if (d.code !== undefined) {
            diagnostic.code = d.code;
        }
        return diagnostic;
    });
}
//# sourceMappingURL=diagnostic.js.map