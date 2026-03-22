"use strict";
/**
 * Application 层 DI 容器初始化器
 *
 * 职责：
 * - 注册所有服务到 DI 容器
 * - 协调领域层服务的创建
 * - 创建适配器并注入到领域层
 *
 * 依赖：domain/, config/, utils/, infrastructure/
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.initializeDIContainer = initializeDIContainer;
exports.reinitializeDIContainer = reinitializeDIContainer;
const config_1 = require("../../config");
const plugin_manager_1 = require("../../domain/plugin-manager");
const shellcheck_plugin_1 = require("../../domain/plugins/shellcheck-plugin");
const shfmt_plugin_1 = require("../../domain/plugins/shfmt-plugin");
const adapters_1 = require("../../infrastructure/adapters");
const performance_metrics_1 = require("../../shared/performance-metrics");
const container_1 = require("../../utils/di/container");
const log_1 = require("../../utils/log");
const monitor_1 = require("../../utils/performance/monitor");
/**
 * 初始化 DI 容器
 * 注册所有服务到容器
 *
 * @param container DI 容器实例
 */
function initializeDIContainer(container) {
    log_1.logger.info("Initializing DI container...");
    // 注册领域层服务
    registerDomainServices(container);
    log_1.logger.info("DI container initialized successfully");
}
/**
 * 注册领域层服务
 */
function registerDomainServices(container) {
    log_1.logger.debug("Registering domain services...");
    // 注册 shfmt 插件
    container.registerSingleton(container_1.ServiceNames.SHFMT_PLUGIN, () => {
        const shfmtPath = config_1.SettingInfo.getShfmtPath();
        const tabSize = config_1.SettingInfo.getRealTabSize() ?? 4; // 提供默认值
        // 创建适配器
        const toolAdapter = new adapters_1.ShfmtToolAdapter(shfmtPath, { tabSize });
        // 创建插件配置
        const pluginConfig = {
            tabSize,
            diagnosticSource: config_1.PackageInfo.diagnosticSource,
            fileExtensions: config_1.PackageInfo.fileExtensions,
        };
        return new shfmt_plugin_1.PureShfmtPlugin(toolAdapter, pluginConfig);
    });
    // 注册 shellcheck 插件
    container.registerSingleton(container_1.ServiceNames.SHELLCHECK_PLUGIN, () => {
        const shellcheckPath = config_1.SettingInfo.getShellcheckPath();
        // 创建适配器
        const toolAdapter = new adapters_1.ShellcheckToolAdapter(shellcheckPath);
        // 创建插件配置
        const pluginConfig = {
            tabSize: config_1.SettingInfo.getRealTabSize() ?? 4, // 提供默认值
            diagnosticSource: config_1.PackageInfo.diagnosticSource,
            fileExtensions: config_1.PackageInfo.fileExtensions,
        };
        return new shellcheck_plugin_1.PureShellcheckPlugin(toolAdapter, pluginConfig);
    });
    // 注册 PluginManager（依赖插件）
    container.registerSingleton(container_1.ServiceNames.PLUGIN_MANAGER, () => {
        const pluginManager = new plugin_manager_1.PluginManager();
        // 注册插件到管理器
        try {
            const shfmtPlugin = container.resolve(container_1.ServiceNames.SHFMT_PLUGIN);
            pluginManager.register(shfmtPlugin);
            log_1.logger.debug("Registered shfmt plugin to PluginManager");
        }
        catch (error) {
            log_1.logger.warn(`Failed to register shfmt plugin: ${String(error)}`);
        }
        try {
            const shellcheckPlugin = container.resolve(container_1.ServiceNames.SHELLCHECK_PLUGIN);
            pluginManager.register(shellcheckPlugin);
            log_1.logger.debug("Registered shellcheck plugin to PluginManager");
        }
        catch (error) {
            log_1.logger.warn(`Failed to register shellcheck plugin: ${String(error)}`);
        }
        return pluginManager;
    }, [container_1.ServiceNames.SHFMT_PLUGIN, container_1.ServiceNames.SHELLCHECK_PLUGIN]);
    log_1.logger.debug("Domain services registered");
}
/**
 * 重新初始化 DI 容器
 * 用于配置变更后重置服务
 *
 * @param container DI 容器实例
 */
function reinitializeDIContainer(container) {
    log_1.logger.info("Reinitializing DI container...");
    const timer = (0, monitor_1.startTimer)(performance_metrics_1.PERFORMANCE_METRICS.DI_CONTAINER_REINITIALIZATION_DURATION);
    // 重置容器（清除所有实例，保留注册）
    container.reset();
    // 重新初始化
    initializeDIContainer(container);
    timer.stop();
    log_1.logger.info("DI container reinitialized");
}
//# sourceMappingURL=initializer.js.map