"use strict";
/**
 * 命令注册器
 * 统一注册所有命令
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerAllCommands = registerAllCommands;
const log_1 = require("../../utils/log");
const fix_command_1 = require("./fix-command");
const format_command_1 = require("./format-command");
const performance_command_1 = require("./performance-command");
const plugin_status_command_1 = require("./plugin-status-command");
/**
 * 注册所有命令
 *
 * @param diagnosticCollection VSCode 诊断集合
 */
function registerAllCommands(diagnosticCollection) {
    log_1.logger.info("Registering all commands");
    return [
        (0, format_command_1.registerFormatDocumentCommand)(),
        (0, fix_command_1.registerFixAllCommand)(diagnosticCollection),
        (0, performance_command_1.registerPerformanceReportCommand)(),
        (0, performance_command_1.registerResetPerformanceCommand)(),
        (0, plugin_status_command_1.registerPluginStatusCommand)(),
    ];
}
//# sourceMappingURL=index.js.map