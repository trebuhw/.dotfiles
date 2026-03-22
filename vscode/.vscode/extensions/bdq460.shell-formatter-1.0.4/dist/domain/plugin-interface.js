"use strict";
/**
 * 插件接口定义
 *
 * 定义格式化工具和检查工具的插件接口
 * 支持动态加载和扩展不同的格式化工具
 *
 * 架构：
 * - IFormatPlugin 扩展 IPlugin（通用插件机制）
 * - 使用领域类型（Document, TextEdit, Diagnostic 等），不依赖 VSCode
 * - 通过适配器层进行 VSCode 类型和领域类型的转换
 *
 * 设计原则：
 * 1. 领域层不依赖外部框架（VSCode、浏览器等）
 * 2. 可在 CLI、Web、桌面应用等多种场景使用
 * 3. 通过适配器层与 VSCode 集成
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.DiagnosticSeverity = void 0;
// 重新导出领域类型
var types_1 = require("./types");
Object.defineProperty(exports, "DiagnosticSeverity", { enumerable: true, get: function () { return types_1.DiagnosticSeverity; } });
//# sourceMappingURL=plugin-interface.js.map