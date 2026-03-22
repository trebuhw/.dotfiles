"use strict";
/**
 * 文档格式化用例
 *
 * 职责：协调领域层完成文档格式化
 * 这是应用层的用例编排，不直接依赖 VSCode
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatDocument = formatDocument;
const performance_metrics_1 = require("../../shared/performance-metrics");
const container_1 = require("../../utils/di/container");
const log_1 = require("../../utils/log");
const monitor_1 = require("../../utils/performance/monitor");
/**
 * 格式化文档
 *
 * 协调领域层的插件管理器完成文档格式化
 *
 * @param document 领域文档对象
 * @param options 格式化选项
 * @param token 取消令牌（可选）
 * @returns 文本编辑数组
 */
async function formatDocument(document, options) {
    log_1.logger.info(`Formatting document: ${document.fileName}`);
    const timer = (0, monitor_1.startTimer)(performance_metrics_1.PERFORMANCE_METRICS.SHFMT_FORMAT_DURATION);
    try {
        // 从 DI 容器获取 PluginManager 实例
        const container = (0, container_1.getContainer)();
        const pluginManager = container.resolve(container_1.ServiceNames.PLUGIN_MANAGER);
        // 检查是否有启用的插件
        const availablePlugins = await pluginManager.getAvailablePlugins();
        if (availablePlugins.length === 0) {
            log_1.logger.warn("No plugins available for formatting");
            timer.stop();
            return [];
        }
        // 执行格式化
        const pluginTimer = (0, monitor_1.startTimer)(performance_metrics_1.PERFORMANCE_METRICS.PLUGIN_EXECUTE_FORMAT_DURATION);
        const result = await pluginManager.format(document, {
            token: options?.token,
        });
        pluginTimer.stop();
        timer.stop();
        log_1.logger.info(`Formatting completed for ${document.fileName}: ${result.textEdits?.length || 0} edits, hasErrors=${result.hasErrors}`);
        return result.textEdits || [];
    }
    catch (error) {
        timer.stop();
        log_1.logger.error(`Failed to format document ${document.fileName}: ${String(error)}`);
        return [];
    }
}
//# sourceMappingURL=format-document.js.map