"use strict";
/**
 * 领域层类型定义
 *
 * 定义不依赖 VSCode 的领域类型
 * 用于插件接口和核心业务逻辑
 *
 * 设计原则：
 * 1. 不依赖任何外部框架（VSCode、浏览器等）
 * 2. 可在 CLI、Web、桌面应用等多种场景使用
 * 3. 通过适配器层与 VSCode 类型进行转换
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.DiagnosticSeverity = void 0;
/**
 * 诊断严重级别
 * 对应 VSCode DiagnosticSeverity 的领域表示
 */
var DiagnosticSeverity;
(function (DiagnosticSeverity) {
    /** 错误 */
    DiagnosticSeverity[DiagnosticSeverity["Error"] = 0] = "Error";
    /** 警告 */
    DiagnosticSeverity[DiagnosticSeverity["Warning"] = 1] = "Warning";
    /** 信息 */
    DiagnosticSeverity[DiagnosticSeverity["Information"] = 2] = "Information";
    /** 提示 */
    DiagnosticSeverity[DiagnosticSeverity["Hint"] = 3] = "Hint";
})(DiagnosticSeverity || (exports.DiagnosticSeverity = DiagnosticSeverity = {}));
//# sourceMappingURL=types.js.map