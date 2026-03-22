"use strict";
/**
 * 适配器模块导出
 *
 * 提供领域层端口的基础设施实现
 * 遵循适配器模式，将外部工具适配到领域接口
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.ShellcheckToolAdapter = exports.ShfmtToolAdapter = void 0;
var shfmt_adapter_1 = require("./shfmt-adapter");
Object.defineProperty(exports, "ShfmtToolAdapter", { enumerable: true, get: function () { return shfmt_adapter_1.ShfmtToolAdapter; } });
var shellcheck_adapter_1 = require("./shellcheck-adapter");
Object.defineProperty(exports, "ShellcheckToolAdapter", { enumerable: true, get: function () { return shellcheck_adapter_1.ShellcheckToolAdapter; } });
//# sourceMappingURL=index.js.map