"use strict";
/**
 * 性能监控服务
 *
 * 职责：
 * - 提供性能计时器的便捷访问
 * - 提供具有业务逻辑的性能分析功能
 *
 * 使用场景：
 * - 启动性能计时
 * - 生成性能摘要和健康检查报告
 *
 * 注意：
 * - 性能指标名称常量从 domain 层导入（PERFORMANCE_METRICS）
 * - utils/performance/integration.ts 提供的通用工具函数应直接从 utils 层导入
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
exports.PERFORMANCE_METRICS = void 0;
exports.startTimer = startTimer;
exports.getPerformanceStats = getPerformanceStats;
exports.getPerformanceSummary = getPerformanceSummary;
exports.checkPerformanceHealth = checkPerformanceHealth;
exports.showPerformanceReport = showPerformanceReport;
const i18n_1 = require("../../i18n");
const log_1 = require("../../utils/log");
const integration_1 = require("../../utils/performance/integration");
const monitor_1 = require("../../utils/performance/monitor");
// 重新导出 domain 层的性能指标常量和 MetricData
var performance_metrics_1 = require("../../shared/performance-metrics");
Object.defineProperty(exports, "PERFORMANCE_METRICS", { enumerable: true, get: function () { return performance_metrics_1.PERFORMANCE_METRICS; } });
/**
 * 创建性能计时器
 *
 * @param metricName 指标名称
 * @returns 性能计时器
 */
function startTimer(metricName) {
    log_1.logger.debug(`Starting timer for metric: ${metricName}`);
    return (0, monitor_1.startTimer)(metricName);
}
/**
 * 获取性能统计信息
 *
 * @returns 性能统计信息
 */
async function getPerformanceStats() {
    const metricNames = (0, integration_1.getAllMetricNames)();
    const metrics = [];
    for (const name of metricNames) {
        const metric = (0, integration_1.getMetricData)(name);
        if (metric) {
            metrics.push(metric);
        }
    }
    return {
        totalMetrics: metricNames.length,
        metrics,
        monitoringEnabled: (0, integration_1.isPerformanceMonitoringEnabled)(),
    };
}
/**
 * 获取性能摘要（用于快速查看）
 *
 * @returns 性能摘要文本
 */
async function getPerformanceSummary() {
    const stats = await getPerformanceStats();
    const lines = [];
    lines.push((0, i18n_1.t)("performance.summaryTitle"));
    lines.push("");
    lines.push((0, i18n_1.t)("performance.monitoring", {
        status: stats.monitoringEnabled ? (0, i18n_1.t)("common.enabled") : (0, i18n_1.t)("common.disabled")
    }));
    lines.push((0, i18n_1.t)("performance.totalMetrics", { count: stats.totalMetrics }));
    lines.push("");
    if (stats.metrics.length > 0) {
        lines.push((0, i18n_1.t)("performance.topMetrics"));
        const sortedMetrics = [...stats.metrics]
            .sort((a, b) => b.count - a.count)
            .slice(0, 5);
        for (const metric of sortedMetrics) {
            lines.push((0, i18n_1.t)("performance.metricLine", {
                name: metric.name,
                count: metric.count,
                avg: metric.avg.toFixed(2)
            }));
        }
        lines.push("");
    }
    lines.push("========================");
    return lines.join("\n");
}
/**
 * 检查系统性能健康状况
 *
 * @returns 健康状态字符串
 */
async function checkPerformanceHealth() {
    const stats = await getPerformanceStats();
    const issues = [];
    // 检查是否有超过阈值的指标
    for (const metric of stats.metrics) {
        if (metric.avg > 5000) {
            issues.push(`Metric "${metric.name}" has high average (${metric.avg.toFixed(2)}ms)`);
        }
    }
    if (issues.length === 0) {
        return "Performance health: OK (no issues detected)";
    }
    return `Performance health: ISSUES DETECTED\n${issues.map((i) => `  - ${i}`).join("\n")}`;
}
/**
 * 生成并显示性能报告
 *
 * @param showContent 显示内容的回调函数（用于输出报告内容）
 */
async function showPerformanceReport(showContent) {
    const { getPerformanceReport, getAlertStats, } = await Promise.resolve().then(() => __importStar(require("../../utils/performance/integration")));
    const report = getPerformanceReport();
    const stats = await getPerformanceStats();
    const alertStats = getAlertStats();
    const summary = await getPerformanceSummary();
    const lines = [];
    lines.push("=".repeat(60));
    lines.push((0, i18n_1.t)("performance.title"));
    lines.push("=".repeat(60));
    lines.push("");
    lines.push((0, i18n_1.t)("performance.reportGenerated", { date: new Date().toLocaleString() }));
    lines.push("");
    lines.push(summary);
    lines.push("");
    lines.push((0, i18n_1.t)("performance.detailedReport"));
    lines.push("");
    lines.push((0, i18n_1.t)("performance.totalMetricsLabel", { count: stats.totalMetrics }));
    lines.push((0, i18n_1.t)("performance.totalAlerts", { count: alertStats.total }));
    lines.push("");
    lines.push(report);
    lines.push("=".repeat(60));
    const content = lines.join("\n");
    showContent(content);
    log_1.logger.info((0, i18n_1.t)("performance.reportGeneratedLog"));
}
//# sourceMappingURL=performance-service.js.map