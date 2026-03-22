"use strict";
/**
 * shfmt 工具类
 * 封装 shfmt 的所有操作
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.ShfmtTool = void 0;
const executor_1 = require("../../../utils/executor");
const parser_1 = require("./parser");
/**
 * shfmt 工具类
 */
class ShfmtTool {
    constructor(commandPath) {
        this.commandPath = commandPath || "shfmt";
    }
    /**
     * 格式化 Shell 脚本
     */
    async format(fileName, options) {
        const args = this.buildFormatArgs(options || {});
        // 如果提供了content，使用stdin模式，添加'-'作为文件名占位符
        const fileNameOrStdin = options?.content ? "-" : fileName;
        args.push(fileNameOrStdin);
        const result = await (0, executor_1.execute)(this.commandPath, {
            args: args,
            token: options?.token,
            stdin: options?.content,
        });
        return (0, parser_1.parseShfmtOutput)(result, "format");
    }
    /**
     * 检查格式
     */
    async check(fileName, options) {
        const args = this.buildCheckArgs(options || {});
        // 如果提供了content，使用stdin模式，添加'-'作为文件名占位符
        const fileNameOrStdin = options?.content ? "-" : fileName;
        args.push(fileNameOrStdin);
        const result = await (0, executor_1.execute)(this.commandPath, {
            args: args,
            token: options?.token,
            stdin: options?.content,
        });
        return (0, parser_1.parseShfmtOutput)(result, "check");
    }
    /**
     * 构建格式化参数
     * 不包括 '-w' 参数，因为该参数用于原地写入文件，而插件使用标准输入输出
     */
    buildFormatArgs(options) {
        const args = [];
        if (options.indent !== undefined) {
            args.push("-i", options.indent.toString());
        }
        if (options.binaryNextLine)
            args.push("-bn");
        if (options.caseIndent)
            args.push("-ci");
        if (options.spaceRedirects)
            args.push("-sr");
        return args;
    }
    /**
     * 构建检查参数
     */
    buildCheckArgs(options) {
        const args = this.buildFormatArgs(options);
        args.push("-d"); // 检查模式
        return args;
    }
}
exports.ShfmtTool = ShfmtTool;
//# sourceMappingURL=shfmt-tool.js.map