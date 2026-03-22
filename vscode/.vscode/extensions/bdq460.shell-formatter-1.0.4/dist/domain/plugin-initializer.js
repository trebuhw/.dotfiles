"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initializePlugins = initializePlugins;
exports.activatePlugins = activatePlugins;
/**
 * 插件初始化器
 *
 * 负责插件的初始化、注册和激活
 * 与 DIContainer 交互来获取和管理插件实例
 *
 * 职责：
 * - 从 DI 容器获取插件实例
 * - 将插件注册到 PluginManager
 * - 根据配置激活已启用的插件
 * - 管理插件的生命周期
 */
// TODO : domain层去除对config的依赖
const config_1 = require("../config");
const performance_metrics_1 = require("../shared/performance-metrics");
const container_1 = require("../utils/di/container");
const log_1 = require("../utils/log");
const monitor_1 = require("../utils/performance/monitor");
/**
 * 初始化和注册所有插件
 * 从 DI 容器获取插件实例，然后注册到 PluginManager
 *
 * @throws 如果获取插件实例或注册失败
 */
async function initializePlugins() {
    log_1.logger.info("Initializing plugins from DI container");
    const timer = (0, monitor_1.startTimer)(performance_metrics_1.PERFORMANCE_METRICS.PLUGIN_LOAD_DURATION);
    try {
        const container = (0, container_1.getContainer)();
        // 从 DI 容器获取插件管理器（已包含注册的插件）
        log_1.logger.info("Getting PluginManager from DI container...");
        container.resolve(container_1.ServiceNames.PLUGIN_MANAGER);
        log_1.logger.info("All plugins initialized and registered successfully");
        // 激活已启用的插件（等待完成）
        await activatePlugins();
        timer.stop();
        log_1.logger.info("Plugin system activated successfully");
    }
    catch (error) {
        timer.stop();
        log_1.logger.error(`Failed to initialize plugins: ${String(error)}`);
        throw error;
    }
}
/**
 * 激活可用插件（基于配置）
 * 只激活用户在配置中启用的插件
 *
 * @throws 如果激活过程失败
 */
async function activatePlugins() {
    log_1.logger.info("Activating enabled plugins...");
    try {
        // 从 DI 容器获取 PluginManager
        const container = (0, container_1.getContainer)();
        const pluginManager = container.resolve(container_1.ServiceNames.PLUGIN_MANAGER);
        // 获取插件启用状态配置
        const shfmtEnabled = config_1.SettingInfo.isShfmtEnabled();
        const shellcheckEnabled = config_1.SettingInfo.isShellcheckEnabled();
        log_1.logger.info(`Plugin configuration: shfmt=${shfmtEnabled}, shellcheck=${shellcheckEnabled}`);
        // 构建需要激活的插件列表
        const pluginsToActivate = [];
        if (shfmtEnabled) {
            pluginsToActivate.push("shfmt");
        }
        if (shellcheckEnabled) {
            pluginsToActivate.push("shellcheck");
        }
        if (pluginsToActivate.length === 0) {
            log_1.logger.warn("No plugins are enabled in configuration");
            return;
        }
        log_1.logger.info(`Activating ${pluginsToActivate.length} enabled plugins...`);
        const successCount = await pluginManager.activateMultiple(pluginsToActivate);
        log_1.logger.info(`Activated ${successCount}/${pluginsToActivate.length} plugins successfully`);
        // 打印插件状态
        const stats = pluginManager.getStats();
        log_1.logger.info(`Plugin stats: ${stats.total} total, ${stats.active} active`);
    }
    catch (error) {
        log_1.logger.error(`Failed to activate plugins: ${String(error)}`);
        throw error;
    }
}
//# sourceMappingURL=plugin-initializer.js.map