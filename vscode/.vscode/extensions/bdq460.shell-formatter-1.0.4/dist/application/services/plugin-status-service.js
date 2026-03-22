"use strict";
/**
 * 插件状态服务
 *
 * 职责：提供插件状态查询和管理功能
 * 属于应用层服务，协调插件状态的各个方面
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAllPluginStatus = getAllPluginStatus;
exports.showPluginStatus = showPluginStatus;
exports.isPluginAvailable = isPluginAvailable;
const log_1 = require("../../utils/log");
const container_1 = require("../../utils/di/container");
/**
 * 获取所有插件状态
 *
 * @returns 插件状态数组
 */
async function getAllPluginStatus() {
    log_1.logger.info("Getting all plugin status");
    // 从 DI 容器获取 PluginManager 实例
    const container = (0, container_1.getContainer)();
    const pluginManager = container.resolve(container_1.ServiceNames.PLUGIN_MANAGER);
    const stats = pluginManager.getStats();
    log_1.logger.info(`Plugin stats: ${stats.total} total, ${stats.active} active`);
    // 构建插件状态列表
    const statuses = [];
    const activePlugins = pluginManager.getActivePluginNames();
    // 获取所有已注册的插件
    for (const pluginName of ["shfmt", "shellcheck"]) {
        const plugin = pluginManager.get(pluginName);
        if (plugin) {
            const isActive = activePlugins.includes(pluginName);
            const isAvailable = await plugin.isAvailable();
            statuses.push({
                name: plugin.name,
                displayName: plugin.displayName,
                version: plugin.version,
                description: plugin.description,
                registered: true,
                active: isActive,
                available: isAvailable,
                capabilities: plugin.getCapabilities ? plugin.getCapabilities() : [],
                dependencies: plugin.getDependencies
                    ? plugin.getDependencies().map((d) => d.name)
                    : [],
            });
        }
    }
    return statuses;
}
/**
 * 显示插件状态
 *
 * 显示当前所有插件的状态信息
 */
async function showPluginStatus() {
    log_1.logger.info("=== Plugin Status ===");
    // 从 DI 容器获取 PluginManager 实例
    const container = (0, container_1.getContainer)();
    const pluginManager = container.resolve(container_1.ServiceNames.PLUGIN_MANAGER);
    const stats = pluginManager.getStats();
    log_1.logger.info(`Total plugins: ${stats.total}`);
    log_1.logger.info(`Active plugins: ${stats.active}`);
    const activePlugins = pluginManager.getActivePluginNames();
    if (activePlugins.length > 0) {
        log_1.logger.info(`Active plugin names: ${activePlugins.join(", ")}`);
    }
    else {
        log_1.logger.info("No active plugins");
    }
    log_1.logger.info("====================");
}
/**
 * 检查插件是否可用
 *
 * @param pluginName 插件名称
 * @returns 是否可用
 */
async function isPluginAvailable(pluginName) {
    log_1.logger.debug(`Checking if plugin "${pluginName}" is available`);
    // 从 DI 容器获取 PluginManager 实例
    const container = (0, container_1.getContainer)();
    const pluginManager = container.resolve(container_1.ServiceNames.PLUGIN_MANAGER);
    const plugin = pluginManager.get(pluginName);
    if (!plugin) {
        return false;
    }
    return plugin.isAvailable();
}
//# sourceMappingURL=plugin-status-service.js.map