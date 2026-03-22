"use strict";
/**
 * 基础类型定义
 * 与业务无关，与 VSCode 无关
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.ErrorType = void 0;
/**
 * 错误类型枚举
 */
var ErrorType;
(function (ErrorType) {
    ErrorType["Timeout"] = "timeout";
    ErrorType["Cancelled"] = "cancelled";
    ErrorType["Execution"] = "execution";
})(ErrorType || (exports.ErrorType = ErrorType = {}));
//# sourceMappingURL=types.js.map