"use strict";
/**
 * 性能告警管理器
 *
 * 职责：
 * - 监控性能指标，超过阈值时触发告警
 * - 支持多级别告警（LOW, MEDIUM, HIGH, CRITICAL）
 * - 提供告警统计和查询功能
 *
 * 使用场景：
 * - 监控格式化、诊断等关键操作的性能
 * - 及时发现性能瓶颈并告警
 * - 收集性能数据用于分析和优化
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.PerformanceAlertManager = exports.AlertLevel = void 0;
exports.getAlertManager = getAlertManager;
exports.setAlertManager = setAlertManager;
exports.resetAlertManager = resetAlertManager;
const log_1 = require("../log");
/**
 * 告警级别
 */
var AlertLevel;
(function (AlertLevel) {
    AlertLevel["LOW"] = "LOW";
    AlertLevel["MEDIUM"] = "MEDIUM";
    AlertLevel["HIGH"] = "HIGH";
    AlertLevel["CRITICAL"] = "CRITICAL";
})(AlertLevel || (exports.AlertLevel = AlertLevel = {}));
/**
 * 性能告警管理器
 */
class PerformanceAlertManager {
    constructor(maxHistorySize = 1000) {
        /** 告警处理器列表 */
        this.handlers = [];
        /** 告警历史 */
        this.alerts = [];
        /** 阈值配置 */
        this.thresholds = new Map();
        /** 最大告警历史记录数 */
        this.maxHistorySize = 1000;
        /** 告警统计 */
        this.stats = {
            total: 0,
            byLevel: {
                [AlertLevel.LOW]: 0,
                [AlertLevel.MEDIUM]: 0,
                [AlertLevel.HIGH]: 0,
                [AlertLevel.CRITICAL]: 0,
            },
            byMetric: {},
        };
        this.maxHistorySize = maxHistorySize;
        this.initializeDefaultThresholds();
        log_1.logger.info("PerformanceAlertManager initialized");
    }
    /**
     * 注册告警阈值
     */
    registerThreshold(config) {
        this.thresholds.set(config.metricName, config);
        log_1.logger.debug(`Registered threshold for metric: ${config.metricName}`);
    }
    /**
     * 检查指标并触发告警
     */
    check(metricName, value) {
        const config = this.thresholds.get(metricName);
        if (!config) {
            return; // 没有配置阈值，不检查
        }
        const alert = this.createAlert(metricName, value, config);
        if (alert) {
            this.triggerAlert(alert);
        }
    }
    /**
     * 注册告警处理器
     */
    onAlert(handler) {
        this.handlers.push(handler);
        log_1.logger.debug(`Alert handler registered, total: ${this.handlers.length}`);
    }
    /**
     * 获取告警历史
     */
    getAlerts(limit) {
        if (limit !== undefined) {
            return this.alerts.slice(-limit);
        }
        return [...this.alerts];
    }
    /**
     * 获取告警统计
     */
    getAlertStats() {
        return {
            total: this.stats.total,
            byLevel: { ...this.stats.byLevel },
            byMetric: { ...this.stats.byMetric },
        };
    }
    /**
     * 清除告警历史
     */
    clear() {
        this.alerts = [];
        this.stats = {
            total: 0,
            byLevel: {
                [AlertLevel.LOW]: 0,
                [AlertLevel.MEDIUM]: 0,
                [AlertLevel.HIGH]: 0,
                [AlertLevel.CRITICAL]: 0,
            },
            byMetric: {},
        };
        log_1.logger.info("Alert history cleared");
    }
    /**
     * 初始化默认阈值配置
     */
    initializeDefaultThresholds() {
        const defaults = [
            {
                metricName: "diagnose_one_doc_duration",
                criticalThreshold: 10000, // 10秒
                highThreshold: 5000, // 5秒
                mediumThreshold: 3000, // 3秒
            },
            {
                metricName: "diagnose_all_docs_duration",
                criticalThreshold: 60000, // 60秒
                highThreshold: 30000, // 30秒
                mediumThreshold: 20000, // 20秒
            },
            {
                metricName: "format_duration",
                criticalThreshold: 5000, // 5秒
                highThreshold: 3000, // 3秒
                mediumThreshold: 2000, // 2秒
            },
            {
                metricName: "shfmt_format_duration",
                criticalThreshold: 3000, // 3秒
                highThreshold: 2000, // 2秒
                mediumThreshold: 1000, // 1秒
            },
            {
                metricName: "shfmt_diagnose_duration",
                criticalThreshold: 5000, // 5秒
                highThreshold: 3000, // 3秒
                mediumThreshold: 2000, // 2秒
            },
            {
                metricName: "shellcheck_diagnose_duration",
                criticalThreshold: 10000, // 10秒
                highThreshold: 5000, // 5秒
                mediumThreshold: 3000, // 3秒
            },
            {
                metricName: "plugin_load_duration",
                criticalThreshold: 10000, // 10秒
                highThreshold: 5000, // 5秒
                mediumThreshold: 2000, // 2秒
            },
            {
                metricName: "service_init_duration",
                criticalThreshold: 10000, // 10秒
                highThreshold: 5000, // 5秒
                mediumThreshold: 3000, // 3秒
            },
        ];
        defaults.forEach((config) => this.registerThreshold(config));
        log_1.logger.info(`Initialized ${defaults.length} default threshold configurations`);
    }
    /**
     * 创建告警
     */
    createAlert(metricName, value, config) {
        let level = null;
        // 从高到低检查阈值
        if (config.criticalThreshold && value >= config.criticalThreshold) {
            level = AlertLevel.CRITICAL;
        }
        else if (config.highThreshold && value >= config.highThreshold) {
            level = AlertLevel.HIGH;
        }
        else if (config.mediumThreshold && value >= config.mediumThreshold) {
            level = AlertLevel.MEDIUM;
        }
        else if (config.lowThreshold && value >= config.lowThreshold) {
            level = AlertLevel.LOW;
        }
        if (!level) {
            return null; // 未超过阈值
        }
        const threshold = config.criticalThreshold ||
            config.highThreshold ||
            config.mediumThreshold ||
            config.lowThreshold;
        return {
            id: this.generateAlertId(),
            metricName,
            value,
            threshold,
            level,
            timestamp: Date.now(),
            message: `Performance alert: ${metricName} = ${value}ms (threshold: ${threshold}ms, level: ${level})`,
        };
    }
    /**
     * 触发告警
     */
    async triggerAlert(alert) {
        // 添加到历史
        this.alerts.push(alert);
        // 更新统计
        this.stats.total++;
        this.stats.byLevel[alert.level]++;
        this.stats.byMetric[alert.metricName] =
            (this.stats.byMetric[alert.metricName] || 0) + 1;
        // 限制历史大小
        if (this.alerts.length > this.maxHistorySize) {
            this.alerts.shift();
        }
        // 记录日志
        log_1.logger.warn(`[PerformanceAlert] ${alert.message}`);
        // 通知处理器
        for (const handler of this.handlers) {
            try {
                const result = handler(alert);
                if (result instanceof Promise) {
                    await result;
                }
            }
            catch (error) {
                log_1.logger.error(`Error in alert handler: ${String(error)}`);
            }
        }
    }
    /**
     * 生成告警 ID
     */
    generateAlertId() {
        return `alert_${Date.now()}_${Math.random().toString(36).slice(2, 11)}`;
    }
}
exports.PerformanceAlertManager = PerformanceAlertManager;
/**
 * 全局告警管理器实例
 */
let globalAlertManager = null;
/**
 * 获取全局告警管理器
 */
function getAlertManager() {
    if (!globalAlertManager) {
        globalAlertManager = new PerformanceAlertManager();
    }
    return globalAlertManager;
}
/**
 * 设置全局告警管理器（主要用于测试）
 */
function setAlertManager(manager) {
    globalAlertManager = manager;
}
/**
 * 重置全局告警管理器（主要用于测试）
 */
function resetAlertManager() {
    if (globalAlertManager) {
        globalAlertManager.clear();
    }
}
//# sourceMappingURL=alert-manager.js.map