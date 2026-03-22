"use strict";
/**
 * 性能报告命令模块
 * 提供查看性能报告的命令注册
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
exports.registerPerformanceReportCommand = registerPerformanceReportCommand;
exports.registerResetPerformanceCommand = registerResetPerformanceCommand;
const vscode = __importStar(require("vscode"));
const application_1 = require("../../application");
const config_1 = require("../../config");
const i18n_1 = require("../../i18n");
const log_1 = require("../../utils/log");
const integration_1 = require("../../utils/performance/integration");
/**
 * 显示性能报告
 */
async function showPerformanceReport() {
    log_1.logger.info("Show performance report command triggered");
    const outputChannel = vscode.window.createOutputChannel("Shell Formatter Performance Report");
    await (0, application_1.showPerformanceReport)((content) => {
        outputChannel.appendLine(content);
        outputChannel.show();
    });
    log_1.logger.info("Performance report displayed");
}
/**
 * 注册性能报告命令
 */
function registerPerformanceReportCommand() {
    log_1.logger.info("Registering performance report command");
    return vscode.commands.registerCommand(config_1.PackageInfo.commandShowPerformanceReport, showPerformanceReport);
}
/**
 * 注册重置性能指标命令
 */
function registerResetPerformanceCommand() {
    log_1.logger.info("Registering reset performance metrics command");
    return vscode.commands.registerCommand(config_1.PackageInfo.commandResetPerformanceMetrics, async () => {
        log_1.logger.info("Reset performance metrics command triggered");
        const confirm = await vscode.window.showWarningMessage((0, i18n_1.t)("messages.confirmResetMetrics"), "Reset", "Cancel");
        if (confirm === "Reset") {
            (0, integration_1.resetMetrics)();
            vscode.window.showInformationMessage((0, i18n_1.t)("messages.resetMetricsSuccess"));
            log_1.logger.info("Performance metrics have been reset");
        }
    });
}
//# sourceMappingURL=performance-command.js.map