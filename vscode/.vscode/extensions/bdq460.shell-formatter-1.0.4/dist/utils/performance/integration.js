"use strict";
/**
 * 性能监控集成模块
 *
 * 为关键操作提供便捷的性能监控接口
 * 统一管理性能指标的记录和报告
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.setAlertManager = exports.resetAlertManager = exports.PerformanceScope = void 0;
exports.measurePerformance = measurePerformance;
exports.wrapAsync = wrapAsync;
exports.measureAsync = measureAsync;
exports.wrapSync = wrapSync;
exports.createPerformanceScope = createPerformanceScope;
exports.recordMetric = recordMetric;
exports.getPerformanceReport = getPerformanceReport;
exports.getAverageMetric = getAverageMetric;
exports.getMetricData = getMetricData;
exports.getAllMetricNames = getAllMetricNames;
exports.resetMetrics = resetMetrics;
exports.resetMetric = resetMetric;
exports.enablePerformanceMonitoring = enablePerformanceMonitoring;
exports.disablePerformanceMonitoring = disablePerformanceMonitoring;
exports.isPerformanceMonitoringEnabled = isPerformanceMonitoringEnabled;
exports.enablePerformanceAlerts = enablePerformanceAlerts;
exports.disablePerformanceAlerts = disablePerformanceAlerts;
exports.onPerformanceAlert = onPerformanceAlert;
exports.setAlertThreshold = setAlertThreshold;
exports.getPerformanceAlerts = getPerformanceAlerts;
exports.getAlertStats = getAlertStats;
exports.clearAlertHistory = clearAlertHistory;
const log_1 = require("../log");
const alert_manager_1 = require("./alert-manager");
Object.defineProperty(exports, "resetAlertManager", { enumerable: true, get: function () { return alert_manager_1.resetAlertManager; } });
Object.defineProperty(exports, "setAlertManager", { enumerable: true, get: function () { return alert_manager_1.setAlertManager; } });
const monitor_1 = require("./monitor");
/**
 * 性能监控装饰器
 * 用于装饰函数，自动记录其执行时间
 *
 * @param metricName 指标名称
 * @returns 方法装饰器
 */
function measurePerformance(metricName) {
    return function (_target, propertyKey, descriptor) {
        const originalMethod = descriptor.value;
        descriptor.value = async function (...args) {
            const timer = new monitor_1.PerformanceTimer(metricName, monitor_1.performanceMonitor);
            log_1.logger.debug(`Starting ${metricName} for ${String(propertyKey)}`);
            try {
                return await originalMethod.apply(this, args);
            }
            finally {
                const duration = timer.stop();
                log_1.logger.debug(`Completed ${metricName} for ${String(propertyKey)}: ${duration}ms`);
            }
        };
        return descriptor;
    };
}
/**
 * 性能监控包装函数
 * 包装一个异步函数，记录其执行时间
 *
 * @param metricName 指标名称
 * @param fn 要包装的异步函数
 * @returns 包装后的异步函数
 */
function wrapAsync(metricName, fn) {
    return async function (...args) {
        const timer = new monitor_1.PerformanceTimer(metricName, monitor_1.performanceMonitor);
        log_1.logger.debug(`Starting ${metricName}`);
        try {
            const result = await fn.apply(this, args);
            const duration = timer.stop();
            log_1.logger.debug(`Completed ${metricName}: ${duration}ms`);
            return result;
        }
        catch (error) {
            const duration = timer.stop();
            log_1.logger.error(`Failed ${metricName} after ${duration}ms: ${String(error)}`);
            throw error;
        }
    };
}
/**
 * 性能监控包装函数（使用 startTimer 便捷函数）
 * 包装一个异步函数，记录其执行时间
 *
 * @param metricName 指标名称
 * @param fn 要包装的异步函数
 * @returns 包装后的异步函数
 */
function measureAsync(metricName, fn) {
    return async function (...args) {
        const timer = (0, monitor_1.startTimer)(metricName);
        log_1.logger.debug(`Starting ${metricName}`);
        try {
            const result = await fn.apply(this, args);
            const duration = timer.stop();
            log_1.logger.debug(`Completed ${metricName}: ${duration}ms`);
            return result;
        }
        catch (error) {
            const duration = timer.stop();
            log_1.logger.error(`Failed ${metricName} after ${duration}ms: ${String(error)}`);
            throw error;
        }
    };
}
/**
 * 同步函数性能监控包装
 * 包装一个同步函数，记录其执行时间
 *
 * @param metricName 指标名称
 * @param fn 要包装的同步函数
 * @returns 包装后的同步函数
 */
function wrapSync(metricName, fn) {
    return function (...args) {
        const timer = new monitor_1.PerformanceTimer(metricName, monitor_1.performanceMonitor);
        log_1.logger.debug(`Starting ${metricName}`);
        try {
            const result = fn.apply(this, args);
            const duration = timer.stop();
            log_1.logger.debug(`Completed ${metricName}: ${duration}ms`);
            return result;
        }
        catch (error) {
            const duration = timer.stop();
            log_1.logger.error(`Failed ${metricName} after ${duration}ms: ${String(error)}`);
            throw error;
        }
    };
}
/**
 * 性能监控上下文管理器
 * 使用 async/await 确保性能监控在函数执行前后正确记录
 *
 * @param metricName 指标名称
 * @returns 异步上下文管理器
 */
class PerformanceScope {
    constructor(metricName) {
        this.metricName = metricName;
        this.timer = new monitor_1.PerformanceTimer(metricName, monitor_1.performanceMonitor);
        log_1.logger.debug(`Starting performance scope: ${metricName}`);
    }
    /**
     * 停止计时并记录
     */
    end() {
        const duration = this.timer.stop();
        log_1.logger.debug(`Ended performance scope ${this.metricName}: ${duration}ms`);
        return duration;
    }
    /**
     * 停止计时并记录（异步）
     */
    async endAsync() {
        const duration = await this.timer.stopAsync();
        log_1.logger.debug(`Ended performance scope ${this.metricName}: ${duration}ms`);
        return duration;
    }
}
exports.PerformanceScope = PerformanceScope;
/**
 * 创建性能监控作用域
 * 推荐使用 with 语句或 try-finally 确保正确清理
 *
 * @param metricName 指标名称
 * @returns 性能监控作用域
 */
function createPerformanceScope(metricName) {
    return new PerformanceScope(metricName);
}
/**
 * 记录自定义指标
 * @param metricName 指标名称
 * @param value 指标值
 */
function recordMetric(metricName, value) {
    monitor_1.performanceMonitor.recordMetric(metricName, value);
    log_1.logger.debug(`Recorded metric ${metricName}: ${value}`);
}
/**
 * 获取性能报告
 * @returns 性能报告字符串
 */
function getPerformanceReport() {
    return monitor_1.performanceMonitor.generateReport();
}
/**
 * 获取指定指标的平均值
 * @param metricName 指标名称
 * @returns 平均值，如果指标不存在则返回 null
 */
function getAverageMetric(metricName) {
    return monitor_1.performanceMonitor.getAverageMetric(metricName);
}
/**
 * 获取指定指标的统计信息
 * @param metricName 指标名称
 * @returns 指标数据，如果指标不存在则返回 null
 */
function getMetricData(metricName) {
    return monitor_1.performanceMonitor.getMetric(metricName);
}
/**
 * 获取所有指标名称
 * @returns 指标名称数组
 */
function getAllMetricNames() {
    return monitor_1.performanceMonitor.getAllMetricNames();
}
/**
 * 重置所有性能指标
 * 主要用于测试或重新开始性能监控
 */
function resetMetrics() {
    log_1.logger.info("Resetting all performance metrics");
    monitor_1.performanceMonitor.reset();
}
/**
 * 重置指定指标
 * @param metricName 指标名称
 */
function resetMetric(metricName) {
    log_1.logger.info(`Resetting performance metric: ${metricName}`);
    monitor_1.performanceMonitor.resetMetric(metricName);
}
/**
 * 启用性能监控
 */
function enablePerformanceMonitoring() {
    log_1.logger.info("Enabling performance monitoring");
    monitor_1.performanceMonitor.enable();
}
/**
 * 禁用性能监控
 */
function disablePerformanceMonitoring() {
    log_1.logger.info("Disabling performance monitoring");
    monitor_1.performanceMonitor.disable();
}
/**
 * 检查性能监控是否启用
 * @returns 是否启用
 */
function isPerformanceMonitoringEnabled() {
    // performanceMonitor 具有 isEnabled 属性，通过接口定义而不是类型转换
    const monitor = monitor_1.performanceMonitor;
    return monitor.isEnabled ?? false;
}
/**
 * 性能告警相关函数
 */
/**
 * 启用性能告警
 * 默认告警阈值在 alertManager.ts 中定义
 */
function enablePerformanceAlerts() {
    log_1.logger.info("Enabling performance alerts");
    // 告警管理器会在性能计时器停止时自动检查
}
/**
 * 禁用性能告警
 */
function disablePerformanceAlerts() {
    log_1.logger.info("Disabling performance alerts");
    (0, alert_manager_1.getAlertManager)().clear();
}
/**
 * 注册告警处理器
 * 当性能超过阈值时，处理器会被调用
 *
 * @param handler 告警处理器
 *
 * 使用示例：
 * ```typescript
 * onPerformanceAlert((alert) => {
 *   console.log(`Performance alert: ${alert.metricName} = ${alert.value}ms`);
 * });
 * ```
 */
function onPerformanceAlert(handler) {
    (0, alert_manager_1.getAlertManager)().onAlert(handler);
    log_1.logger.info(`Performance alert handler registered`);
}
/**
 * 设置告警阈值
 *
 * @param metricName 指标名称
 * @param threshold 阈值（毫秒）
 * @param level 告警级别（可选，默认 MEDIUM）
 *
 * 使用示例：
 * ```typescript
 * setAlertThreshold("format_duration", 2000, AlertLevel.MEDIUM);
 * ```
 */
function setAlertThreshold(metricName, threshold, level = alert_manager_1.AlertLevel.MEDIUM) {
    log_1.logger.info(`Setting alert threshold for ${metricName}: ${threshold}ms (${level})`);
    // 注意：这里需要扩展 alertManager 以支持单个阈值设置
    // 当前实现使用多个级别阈值，这里仅作为占位符
}
/**
 * 获取告警历史
 *
 * @param limit 限制返回的告警数量（可选）
 * @returns 告警列表
 *
 * 使用示例：
 * ```typescript
 * const alerts = getPerformanceAlerts(10);
 * console.log(`Recent alerts: ${alerts.length}`);
 * ```
 */
function getPerformanceAlerts(limit) {
    return (0, alert_manager_1.getAlertManager)().getAlerts(limit);
}
/**
 * 获取告警统计信息
 *
 * @returns 告警统计
 *
 * 使用示例：
 * ```typescript
 * const stats = getAlertStats();
 * console.log(`Total alerts: ${stats.total}`);
 * console.log(`Critical: ${stats.byLevel.CRITICAL}`);
 * ```
 */
function getAlertStats() {
    return (0, alert_manager_1.getAlertManager)().getAlertStats();
}
/**
 * 清除告警历史
 */
function clearAlertHistory() {
    log_1.logger.info("Clearing alert history");
    (0, alert_manager_1.getAlertManager)().clear();
}
//# sourceMappingURL=integration.js.map