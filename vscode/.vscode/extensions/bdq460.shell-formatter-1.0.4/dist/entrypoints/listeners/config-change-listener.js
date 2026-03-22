"use strict";
/**
 * 配置变更监听器
 *
 * 职责：监听 VSCode 配置变更事件，重新初始化插件系统
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
exports.registerConfigChangeListener = registerConfigChangeListener;
const vscode = __importStar(require("vscode"));
const application_1 = require("../../application");
const config_1 = require("../../config");
const plugin_initializer_1 = require("../../domain/plugin-initializer");
const i18n_1 = require("../../i18n");
const performance_metrics_1 = require("../../shared/performance-metrics");
const container_1 = require("../../utils/di/container");
const log_1 = require("../../utils/log");
const monitor_1 = require("../../utils/performance/monitor");
/**
 * 注册配置变更监听器
 *
 * @param diagnosticCollection VSCode 诊断集合（已弃用，保留兼容性）
 * @param debounceManager 防抖管理器
 */
function registerConfigChangeListener(diagnosticCollection, debounceManager) {
    void diagnosticCollection; // 显式声明以避免 linter 警告
    // onDidChangeConfiguration会监听配置变化, 包括用户settings.json或工作区.vscode/settings.json所有配置变化
    log_1.logger.info("Registering configuration change listener");
    return vscode.workspace.onDidChangeConfiguration(async (event) => {
        log_1.logger.info(`Configuration change event happened! event:${event}`);
        // 检查语言配置是否变化
        const languageConfigKey = `${config_1.SettingInfo.configSectionName}.language`;
        const languageChanged = event.affectsConfiguration(languageConfigKey);
        // 检查扩展相关配置是否变化
        if (languageChanged || config_1.SettingInfo.isConfigurationChanged(event)) {
            const timer = (0, monitor_1.startTimer)(performance_metrics_1.PERFORMANCE_METRICS.CONFIGURATION_CHANGE_HANDLER_DURATION);
            try {
                log_1.logger.info("Extension relevant configuration changed");
                // 步骤 1: 刷新 SettingInfo 的配置缓存
                // 这是核心：所有配置缓存在 SettingInfo 中统一管理
                config_1.SettingInfo.refreshCache();
                // 步骤 2: 如果语言配置变化，重新初始化 i18n 系统
                if (languageChanged) {
                    const newLanguage = config_1.SettingInfo.getLanguage();
                    log_1.logger.info(`Language configuration changed to: ${newLanguage}`);
                    (0, i18n_1.initializeI18n)(newLanguage);
                    log_1.logger.info("i18n system reinitialized with new language.");
                }
                // 步骤 3: 重新初始化插件系统（配置变化可能影响插件参数）
                log_1.logger.info("Reinitializing plugins due to configuration change");
                const container = (0, container_1.getContainer)();
                container.reset(); // 清除所有单例实例
                (0, application_1.initializeDIContainer)(container); // 重新注册所有服务
                await (0, plugin_initializer_1.initializePlugins)(); // 重新初始化插件（等待完成）
                // 步骤 4: 清除所有活跃的防抖定时器
                debounceManager.clearAll();
                timer.stop();
                log_1.logger.info("Configuration change handled successfully");
            }
            catch (error) {
                timer.stop();
                log_1.logger.error(`Error handling configuration change: ${String(error)}`);
            }
        }
    });
}
//# sourceMappingURL=config-change-listener.js.map