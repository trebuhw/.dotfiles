"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.diagnoseDocument = diagnoseDocument;
/**
 * 文档诊断用例
 *
 * 职责：协调领域层完成文档诊断
 * 这是应用层的用例编排，不直接依赖 VSCode
 */
// TODO : application层去除对config的依赖
const config_1 = require("../../config");
const performance_metrics_1 = require("../../shared/performance-metrics");
const container_1 = require("../../utils/di/container");
const log_1 = require("../../utils/log");
const monitor_1 = require("../../utils/performance/monitor");
/**
 * 诊断文档
 *
 * 协调领域层的插件管理器完成文档诊断
 *
 * @param document 领域文档对象
 * @param token 取消令牌（可选）
 * @returns VSCode 诊断数组
 */
async function diagnoseDocument(document, token) {
    log_1.logger.info(`Diagnosing document: ${document.fileName}`);
    const timer = (0, monitor_1.startTimer)(performance_metrics_1.PERFORMANCE_METRICS.SHELLCHECK_DIAGNOSE_DURATION);
    try {
        // 从 DI 容器获取 PluginManager 实例
        const container = (0, container_1.getContainer)();
        const pluginManager = container.resolve(container_1.ServiceNames.PLUGIN_MANAGER);
        // 检查是否有启用的插件
        const availablePlugins = await pluginManager.getAvailablePlugins();
        if (availablePlugins.length === 0) {
            log_1.logger.warn("No plugins available for diagnosis");
            timer.stop();
            return [];
        }
        // 执行诊断
        const pluginTimer = (0, monitor_1.startTimer)(performance_metrics_1.PERFORMANCE_METRICS.PLUGIN_EXECUTE_CHECK_DURATION);
        const result = await pluginManager.check(document, {
            token,
        });
        pluginTimer.stop();
        timer.stop();
        log_1.logger.info(`Diagnosis completed for ${document.fileName}: ${result.diagnostics.length} diagnostics, hasErrors=${result.hasErrors}`);
        return result.diagnostics;
    }
    catch (error) {
        timer.stop();
        log_1.logger.error(`Failed to diagnose document ${document.fileName}: ${String(error)}`);
        // 返回执行错误诊断
        return [
            {
                range: {
                    start: { line: 0, character: 0 },
                    end: { line: 0, character: 0 },
                },
                message: `Diagnosis failed: ${String(error)}`,
                severity: 0, // DiagnosticSeverity.Error
                code: "diagnosis-error",
                source: config_1.PackageInfo.diagnosticSource,
            },
        ];
    }
}
//# sourceMappingURL=diagnose-document.js.map