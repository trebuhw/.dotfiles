"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ServiceNames = exports.DIContainer = void 0;
exports.getContainer = getContainer;
exports.setContainer = setContainer;
exports.resetContainer = resetContainer;
exports.clearContainer = clearContainer;
/**
 * 判断对象是否实现了 ICleanup 接口
 */
function hasCleanup(obj) {
    return obj && typeof obj.cleanup === "function";
}
const log_1 = require("../log");
/**
 * 依赖注入容器
 */
class DIContainer {
    constructor() {
        /**
         * 清理所有已创建的服务
         * 调用所有实现了 ICleanup 接口的服务的 cleanup() 方法
         * @returns Promise，在所有清理操作完成后 resolve
         */
        this.services = new Map();
        this.creatingStack = new Set();
    }
    /**
     * 注册服务（单例）
     * @param name 服务名称
     * @param factory 服务工厂函数
     * @param dependencies 依赖的服务名称列表
     */
    registerSingleton(name, factory, dependencies = []) {
        if (this.services.has(name)) {
            log_1.logger.warn(`Service "${name}" is already registered, will be overwritten`);
        }
        this.services.set(name, {
            factory: factory,
            instantiated: false,
            dependencies,
            isSingleton: true,
        });
        log_1.logger.debug(`Registered singleton service: ${name}`);
    }
    /**
     * 注册服务（工厂模式 - 每次返回新实例）
     * @param name 服务名称
     * @param factory 服务工厂函数
     * @param dependencies 依赖的服务名称列表
     */
    registerTransient(name, factory, dependencies = []) {
        if (this.services.has(name)) {
            log_1.logger.warn(`Service "${name}" is already registered, will be overwritten`);
        }
        this.services.set(name, {
            factory: factory,
            instantiated: false,
            dependencies,
            isSingleton: false,
        });
        log_1.logger.debug(`Registered transient service: ${name}`);
    }
    /**
     * 解析并获取服务实例
     * @param name 服务名称
     * @returns 服务实例
     * @throws 如果服务不存在或检测到循环依赖
     */
    resolve(name) {
        const service = this.services.get(name);
        if (!service) {
            throw new Error(`Service "${name}" is not registered`);
        }
        // 检测循环依赖
        if (this.creatingStack.has(name)) {
            const cycle = Array.from(this.creatingStack).concat([name]).join(" -> ");
            throw new Error(`Circular dependency detected: ${cycle}`);
        }
        // 如果是单例且已实例化，直接返回
        if (service.isSingleton && service.instantiated && service.instance !== undefined) {
            log_1.logger.debug(`Resolving existing singleton: ${name}`);
            return service.instance;
        }
        // 创建新实例
        this.creatingStack.add(name);
        try {
            log_1.logger.debug(`Creating new instance: ${name}`);
            const instance = service.factory();
            // 如果是单例，缓存实例
            if (service.isSingleton) {
                service.instantiated = true;
                service.instance = instance;
            }
            return instance;
        }
        finally {
            this.creatingStack.delete(name);
        }
    }
    /**
     * 检查服务是否已注册
     * @param name 服务名称
     * @returns 是否已注册
     */
    has(name) {
        return this.services.has(name);
    }
    /**
     * 重置所有服务（主要用于测试）
     * 清除所有实例，但保留注册
     */
    reset() {
        log_1.logger.info("Resetting DI container");
        for (const [, metadata] of this.services.entries()) {
            metadata.instantiated = false;
            metadata.instance = undefined;
        }
        this.creatingStack.clear();
    }
    /**
     * 清理所有已创建的服务
     * 调用所有实现了 ICleanup 接口的服务的 cleanup() 方法
     * @returns Promise，在所有清理操作完成后 resolve
     */
    async cleanup() {
        log_1.logger.info("Cleaning up DI container services");
        const cleanupPromises = [];
        for (const [name, metadata] of this.services.entries()) {
            // 只清理已实例化的服务
            if (metadata.instantiated && metadata.instance) {
                if (hasCleanup(metadata.instance)) {
                    try {
                        const result = metadata.instance.cleanup();
                        // 处理异步清理
                        if (result &&
                            typeof result.then === "function") {
                            cleanupPromises.push(result);
                        }
                        log_1.logger.debug(`Cleaned up service: ${name}`);
                    }
                    catch (error) {
                        log_1.logger.error(`Error cleaning up service "${name}": ${String(error)}`);
                    }
                }
            }
        }
        // 等待所有异步清理操作完成
        if (cleanupPromises.length > 0) {
            try {
                await Promise.all(cleanupPromises);
                log_1.logger.info(`${cleanupPromises.length} async cleanup operations completed`);
            }
            catch (error) {
                log_1.logger.error(`Error during async cleanup: ${String(error)}`);
            }
        }
        log_1.logger.info("DI container cleanup completed");
    }
    /**
     * 清除所有服务注册和实例（主要用于测试）
     */
    clear() {
        log_1.logger.info("Clearing DI container");
        this.services.clear();
        this.creatingStack.clear();
    }
    /**
     * 获取所有已注册的服务名称
     * @returns 服务名称数组
     */
    getRegisteredServices() {
        return Array.from(this.services.keys());
    }
    /**
     * 获取服务统计信息（用于调试）
     * @returns 服务统计信息
     */
    getStats() {
        const services = Array.from(this.services.entries()).map(([name, metadata]) => ({
            name,
            instantiated: metadata.instantiated,
            dependencies: metadata.dependencies,
        }));
        return {
            total: services.length,
            instantiated: services.filter((s) => s.instantiated).length,
            services,
        };
    }
}
exports.DIContainer = DIContainer;
/**
 * 全局容器实例
 */
let globalContainer = null;
/**
 * 获取全局容器实例
 * @returns DI容器实例
 */
function getContainer() {
    if (!globalContainer) {
        globalContainer = new DIContainer();
        log_1.logger.info("Global DI container initialized");
    }
    return globalContainer;
}
/**
 * 设置全局容器实例（主要用于测试）
 * @param container DI容器实例
 */
function setContainer(container) {
    globalContainer = container;
}
/**
 * 重置全局容器（主要用于测试）
 */
function resetContainer() {
    if (globalContainer) {
        globalContainer.reset();
    }
}
/**
 * 清除全局容器（主要用于测试）
 */
function clearContainer() {
    globalContainer = null;
}
// 导出 ServiceNames 从 initializer
var initializer_1 = require("./initializer");
Object.defineProperty(exports, "ServiceNames", { enumerable: true, get: function () { return initializer_1.ServiceNames; } });
//# sourceMappingURL=container.js.map