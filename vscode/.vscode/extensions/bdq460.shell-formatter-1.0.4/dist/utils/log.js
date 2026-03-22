"use strict";
/**
 * 日志模块 - 提供统一的日志级别定义和工具函数
 *
 * 特点：
 * - 统一的日志级别定义
 * - 日志级别的数值映射和比较能力
 * - 灵活的日志记录器接口
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.logger = exports.LOG_LEVEL_VALUES = exports.LogLevel = void 0;
exports.getLogLevelRank = getLogLevelRank;
exports.shouldLogByLevel = shouldLogByLevel;
exports.setLogger = setLogger;
exports.resetLogger = resetLogger;
// ==================== 日志级别定义 ====================
/**
 * 日志级别枚举
 *
 * 取值：
 * - DEBUG (0): 调试级别 - 开发调试使用
 * - INFO (1):  信息级别 - 一般信息提示
 * - WARN (2):  警告级别 - 潜在问题
 * - ERROR (3): 错误级别 - 严重问题
 *
 * 与 ErrorSeverity 一致，便于复用
 */
var LogLevel;
(function (LogLevel) {
    LogLevel["DEBUG"] = "debug";
    LogLevel["INFO"] = "info";
    LogLevel["WARN"] = "warn";
    LogLevel["ERROR"] = "error";
})(LogLevel || (exports.LogLevel = LogLevel = {}));
/**
 * 日志级别的数值排序
 *
 * 用途：
 * 1. 比较日志严重程度（值越大越严重）
 * 2. 判断是否应该输出日志
 *
 * 映射关系：
 * DEBUG=0 < INFO=1 < WARN=2 < ERROR=3
 */
exports.LOG_LEVEL_VALUES = {
    [LogLevel.DEBUG]: 0,
    [LogLevel.INFO]: 1,
    [LogLevel.WARN]: 2,
    [LogLevel.ERROR]: 3,
};
// ==================== 日志级别工具函数 ====================
/**
 * 获取日志级别的数值等级
 *
 * 将日志级别转换为数值，用于级别比较
 *
 * @param level 日志级别（支持枚举值或字符串）
 * @returns 日志级别的数值等级（0-3）
 *
 * 示例：
 * ```
 * getLogLevelRank(LogLevel.INFO) // 返回 1
 * getLogLevelRank("warn")        // 返回 2
 * ```
 */
function getLogLevelRank(level) {
    const normalized = typeof level === "string" ? level.toLowerCase() : level;
    return exports.LOG_LEVEL_VALUES[normalized] ?? exports.LOG_LEVEL_VALUES[LogLevel.INFO];
}
/**
 * 判断指定消息级别是否应该输出
 *
 * 通过比较消息级别和配置级别来决定：
 * - 如果 messageLevel >= configLevel，返回 true（应该输出）
 * - 否则返回 false（不输出）
 *
 * @param messageLevel 消息的日志级别
 * @param configLevel  配置的日志级别阈值
 * @returns 是否应该输出该日志
 *
 * 示例：
 * ```
 * // 配置级别为 INFO (1)
 * shouldLogByLevel(LogLevel.DEBUG, LogLevel.INFO) // false (0 < 1)
 * shouldLogByLevel(LogLevel.INFO,  LogLevel.INFO) // true  (1 >= 1)
 * shouldLogByLevel(LogLevel.WARN,  LogLevel.INFO) // true  (2 >= 1)
 * ```
 */
function shouldLogByLevel(messageLevel, configLevel) {
    const messageRank = getLogLevelRank(messageLevel);
    const configRank = getLogLevelRank(configLevel);
    return messageRank >= configRank;
}
/**
 * 设置日志记录器实现
 *
 * 必须在扩展启动的早期阶段调用
 *
 * @param log 日志记录器的实现
 *
 * 示例：
 * ```
 * import { LoggerAdapter } from './adapters/loggerAdapter';
 * setLogger(new LoggerAdapter());
 * ```
 */
function setLogger(log) {
    console.log("Set logger");
    if (!exports.logger) {
        console.log("logger is null set by param");
        exports.logger = log;
    }
}
/**
 * 重置日志记录器（仅用于测试）
 *
 * 警告：此函数仅应在测试环境中使用
 */
function resetLogger() {
    exports.logger = undefined;
}
//# sourceMappingURL=log.js.map