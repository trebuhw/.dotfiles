"use strict";
/**
 * 插件状态命令模块
 * 提供查看插件状态的命令注册
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
exports.registerPluginStatusCommand = registerPluginStatusCommand;
const vscode = __importStar(require("vscode"));
const application_1 = require("../../application");
const config_1 = require("../../config");
const i18n_1 = require("../../i18n");
const log_1 = require("../../utils/log");
/**
 * 显示插件状态
 */
async function showPluginStatus() {
    // 通过 application 层获取插件状态
    const statuses = await (0, application_1.getAllPluginStatus)();
    const report = [];
    report.push("=".repeat(60));
    report.push((0, i18n_1.t)("pluginStatus.title"));
    report.push("=".repeat(60));
    report.push("");
    // 配置状态
    report.push((0, i18n_1.t)("pluginStatus.configuration"));
    report.push((0, i18n_1.t)("pluginStatus.shfmt", {
        status: config_1.SettingInfo.isShfmtEnabled() ? (0, i18n_1.t)("common.enabled") : (0, i18n_1.t)("common.disabled")
    }));
    report.push((0, i18n_1.t)("pluginStatus.shellcheck", {
        status: config_1.SettingInfo.isShellcheckEnabled() ? (0, i18n_1.t)("common.enabled") : (0, i18n_1.t)("common.disabled")
    }));
    report.push("");
    // 注册插件
    report.push((0, i18n_1.t)("pluginStatus.registeredPlugins", { count: statuses.length }));
    report.push("-".repeat(60));
    if (statuses.length === 0) {
        report.push((0, i18n_1.t)("pluginStatus.noPluginsRegistered"));
    }
    else {
        for (const plugin of statuses) {
            const status = plugin.active ? `✓ ${(0, i18n_1.t)("common.active")}` : `✗ ${(0, i18n_1.t)("common.inactive")}`;
            report.push((0, i18n_1.t)("pluginStatus.pluginLine", {
                name: plugin.name,
                displayName: plugin.displayName,
                version: plugin.version,
                status
            }));
        }
    }
    report.push("");
    const activeCount = statuses.filter(p => p.active).length;
    report.push((0, i18n_1.t)("pluginStatus.activePlugins", { count: activeCount }));
    report.push("=".repeat(60));
    // 创建输出通道显示状态报告
    const outputChannel = vscode.window.createOutputChannel("Shell Formatter Plugin Status");
    outputChannel.appendLine(report.join("\n"));
    outputChannel.show();
    log_1.logger.info((0, i18n_1.t)("pluginStatus.statusDisplayed"));
}
/**
 * 注册插件状态命令
 */
function registerPluginStatusCommand() {
    log_1.logger.info("Registering plugin status command");
    return vscode.commands.registerCommand(config_1.PackageInfo.commandShowPluginStatus, async () => {
        log_1.logger.info("Show plugin status command triggered");
        await showPluginStatus();
    });
}
//# sourceMappingURL=plugin-status-command.js.map