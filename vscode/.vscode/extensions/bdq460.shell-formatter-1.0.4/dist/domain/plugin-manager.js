"use strict";
/**
 * 插件管理器 - 领域层
 *
 * 管理格式化和检查插件的注册、加载和调用
 * 支持动态加载和插件生命周期管理
 *
 * 架构：
 * - 使用通用 PluginManager 管理插件生命周期
 * - 使用领域类型（Document, Diagnostic, TextEdit 等），不依赖 VSCode
 * - 可在 CLI、Web、桌面应用等多种场景使用
 *
 * 注意：
 * - 本文件属于领域层，不依赖任何外部框架
 * - VSCode 集成请使用 adapters/vscodePluginAdapter.ts
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.PluginManager = void 0;
exports.getPluginManager = getPluginManager;
exports.setPluginManager = setPluginManager;
exports.resetPluginManager = resetPluginManager;
const utils_1 = require("../utils");
const plugin_1 = require("../utils/plugin");
/**
 * VSCode 插件管理器
 *
 * 继承通用插件管理器的功能，添加 VSCode 特定的格式化和检查方法
 */
class PluginManager {
    constructor() {
        this.baseManager = new plugin_1.PluginManager({
            // 不在钩子失败时抛出异常，只记录日志
            throwOnActivationError: false,
            throwOnDeactivationError: false,
        });
    }
    /**
     * 注册插件
     * @param plugin 插件实例
     */
    register(plugin) {
        this.baseManager.register(plugin);
        utils_1.logger.info(`Registered plugin: ${plugin.name} v${plugin.version} (${plugin.displayName})`);
    }
    /**
     * 注销插件
     * @param name 插件名称
     */
    async unregister(name) {
        await this.baseManager.unregister(name);
        utils_1.logger.info(`Unregistered plugin: ${name}`);
    }
    /**
     * 获取插件
     * @param name 插件名称
     * @returns 插件实例，如果不存在则返回 undefined
     */
    get(name) {
        return this.baseManager.get(name);
    }
    /**
     * 检查插件是否已注册
     * @param name 插件名称
     * @returns 是否已注册
     */
    has(name) {
        return this.baseManager.has(name);
    }
    /**
     * 获取所有已注册的插件
     * @returns 插件实例数组
     */
    getAll() {
        return this.baseManager.getAll();
    }
    /**
     * 获取可用的插件
     * @returns 可用的插件数组
     */
    async getAvailablePlugins() {
        utils_1.logger.info(`Checking availability of plugins`);
        const plugins = await this.baseManager.getAvailablePlugins();
        utils_1.logger.info(`Available plugins: ${plugins.length}/${this.baseManager.getStats().total}`);
        return plugins;
    }
    /**
     * 使用所有活动插件格式化文档
     * @param document 领域文档对象
     * @param options 格式化选项
     * @returns 格式化结果（领域类型）
     */
    async format(document, options) {
        const activePluginNames = this.baseManager.getActivePluginNames();
        utils_1.logger.info(`Formatting document: ${document.fileName} with ${activePluginNames.length} active plugins`);
        if (activePluginNames.length === 0) {
            utils_1.logger.warn("No active plugins available for formatting");
            return {
                hasErrors: true,
                diagnostics: [],
                textEdits: [],
            };
        }
        const allDiagnostics = [];
        const errors = [];
        let hasErrors = false;
        for (const name of activePluginNames) {
            const plugin = this.baseManager.get(name);
            if (plugin) {
                try {
                    utils_1.logger.debug(`Attempting to format with plugin: ${name}`);
                    if (!plugin.format) {
                        utils_1.logger.debug(`Plugin "${name}" does not implement format(), skipping`);
                        continue;
                    }
                    const result = await plugin.format(document, options);
                    // 收集诊断信息
                    if (result.diagnostics && result.diagnostics.length > 0) {
                        allDiagnostics.push(...result.diagnostics);
                    }
                    // 检查是否有错误
                    if (result.hasErrors) {
                        hasErrors = true;
                    }
                    // 如果有文本编辑，返回结果
                    if (result.textEdits && result.textEdits.length > 0) {
                        utils_1.logger.info(`Successfully formatted with plugin: ${name} (${result.textEdits.length} edits)`);
                        return {
                            hasErrors,
                            diagnostics: allDiagnostics,
                            textEdits: result.textEdits,
                        };
                    }
                    else {
                        utils_1.logger.debug(`Plugin "${name}" returned no edits, trying next plugin`);
                    }
                }
                catch (error) {
                    const msg = `Plugin "${name}" format failed: ${String(error)}, trying next plugin`;
                    utils_1.logger.error(msg);
                    errors.push(msg);
                    hasErrors = true;
                    // 将异常错误转化为 diagnostic
                    const errorDiagnostic = this.createErrorDiagnostic(msg, document, name);
                    allDiagnostics.push(errorDiagnostic);
                }
            }
        }
        if (errors.length > 0) {
            utils_1.logger.warn(`Format errors: \n${errors.join("\n")}`);
        }
        utils_1.logger.info(`No text edits returned for document: ${document.fileName}`);
        return {
            hasErrors,
            diagnostics: allDiagnostics,
            textEdits: [],
        };
    }
    /**
     * 使用所有活动插件检查文档
     * @param document 领域文档对象
     * @param options 检查选项
     * @returns 所有插件的诊断结果合并（领域类型）
     */
    async check(document, options) {
        const activePluginNames = this.baseManager.getActivePluginNames();
        utils_1.logger.info(`Checking document: ${document.fileName} with ${activePluginNames.length} active plugins`);
        if (activePluginNames.length === 0) {
            utils_1.logger.warn("No active plugins available for checking");
            return {
                hasErrors: false,
                diagnostics: [],
            };
        }
        const allDiagnostics = [];
        let hasErrors = false;
        const errors = [];
        for (const name of activePluginNames) {
            const plugin = this.baseManager.get(name);
            if (plugin) {
                try {
                    utils_1.logger.debug(`Checking with plugin: ${name}`);
                    const result = await plugin.check(document, options);
                    if (result.diagnostics) {
                        allDiagnostics.push(...result.diagnostics);
                        utils_1.logger.debug(`Plugin "${name}" returned ${result.diagnostics.length} diagnostics`);
                    }
                    if (result.hasErrors) {
                        hasErrors = true;
                    }
                }
                catch (error) {
                    const msg = `Plugin "${name}" check failed: ${String(error)}`;
                    utils_1.logger.error(msg);
                    errors.push(msg);
                    hasErrors = true;
                    // 将异常错误转化为 diagnostic
                    const errorDiagnostic = this.createErrorDiagnostic(msg, document, name);
                    allDiagnostics.push(errorDiagnostic);
                }
            }
        }
        if (errors.length > 0) {
            utils_1.logger.warn(`Check errors: \n${errors.join("\n")}`);
        }
        utils_1.logger.info(`Checking completed: ${allDiagnostics.length} total diagnostics from ${activePluginNames.length} plugins`);
        return {
            hasErrors,
            diagnostics: allDiagnostics,
        };
    }
    /**
     * 清除所有插件
     */
    clear() {
        this.baseManager.clear();
        utils_1.logger.info("Cleared all plugins");
    }
    /**
     * 将错误消息转化为 Diagnostic
     * @param errorMessage 错误消息
     * @param document 领域文档对象
     * @param source 错误来源（插件名称）
     * @returns Diagnostic 对象（领域类型）
     */
    createErrorDiagnostic(errorMessage, _document, source) {
        // 使用文档的第一行或空文档的默认位置
        const range = {
            start: { line: 0, character: 0 },
            end: { line: 0, character: 0 },
        };
        return {
            range,
            message: errorMessage,
            severity: 0, // DiagnosticSeverity.Error
            source,
        };
    }
    /**
     * 停用所有插件
     */
    async deactivateAll() {
        await this.baseManager.deactivateAll();
        utils_1.logger.info(`Deactivated all plugins`);
    }
    /**
     * 重新激活插件（先停用所有，再激活指定插件）
     * @param names 插件名称数组
     * @returns 成功激活的插件数量
     */
    async reactivate(names) {
        utils_1.logger.info("Reactivating plugins: deactivate all then activate selected");
        return this.baseManager.reactivate(names);
    }
    /**
     * 批量激活插件（并行执行以提升性能）
     * @param names 插件名称数组
     * @returns 成功激活的插件数量
     */
    async activateMultiple(names) {
        utils_1.logger.info(`Activating ${names.length} plugins`);
        const successCount = await this.baseManager.activateMultiple(names);
        return successCount;
    }
    /**
     * 激活插件
     * @param name 插件名称
     * @returns 是否激活成功
     */
    async activate(name) {
        return this.baseManager.activate(name);
    }
    /**
     * 停用插件
     * @param name 插件名称
     * @returns 是否停用成功
     */
    async deactivate(name) {
        return this.baseManager.deactivate(name);
    }
    /**
     * 检查插件是否处于活动状态
     * @param name 插件名称
     * @returns 是否活动
     */
    isActive(name) {
        return this.baseManager.isActive(name);
    }
    /**
     * 获取所有活动插件的名称
     * @returns 活动插件名称数组
     */
    getActivePluginNames() {
        return this.baseManager.getActivePluginNames();
    }
    /**
     * 获取插件统计信息
     * @returns 插件统计信息
     */
    getStats() {
        return this.baseManager.getStats();
    }
}
exports.PluginManager = PluginManager;
/**
 * 全局插件管理器实例
 */
let globalPluginManager = null;
/**
 * 获取全局插件管理器实例
 * @returns 插件管理器实例
 */
function getPluginManager() {
    if (!globalPluginManager) {
        globalPluginManager = new PluginManager();
        utils_1.logger.info("Global plugin manager initialized");
    }
    return globalPluginManager;
}
/**
 * 设置全局插件管理器实例（主要用于测试）
 * @param manager 插件管理器实例
 */
function setPluginManager(manager) {
    globalPluginManager = manager;
}
/**
 * 重置全局插件管理器（主要用于测试）
 */
function resetPluginManager() {
    if (globalPluginManager) {
        globalPluginManager.clear();
    }
}
//# sourceMappingURL=plugin-manager.js.map