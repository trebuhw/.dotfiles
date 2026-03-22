"use strict";
/**
 * shellcheck 工具类
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.ShellcheckTool = void 0;
const executor_1 = require("../../../utils/executor");
const parser_1 = require("./parser");
/**
 * shellcheck 工具类
 */
class ShellcheckTool {
    constructor(commandPath) {
        this.defaultArges = ["-f", "gcc"];
        this.commandPath = commandPath || "shellcheck";
    }
    /**
     * 检查 Shell 脚本
     */
    async check(options) {
        const args = [...(options.commandArgs || this.defaultArges)];
        // 如果提供了content，使用stdin模式，添加'-'作为文件名占位符
        const fileNameOrStdin = options.content ? "-" : options.file;
        args.push(fileNameOrStdin);
        const executeOptions = {
            args,
            token: options.token,
            stdin: options.content,
        };
        const result = await (0, executor_1.execute)(this.commandPath, executeOptions);
        return (0, parser_1.parseShellcheckOutput)(result);
    }
}
exports.ShellcheckTool = ShellcheckTool;
//# sourceMappingURL=shellcheck-tool.js.map