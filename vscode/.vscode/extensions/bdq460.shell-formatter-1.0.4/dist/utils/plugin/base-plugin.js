"use strict";
/**
 * 通用插件基类
 *
 * 提供插件的通用实现和工具方法
 * 子类只需实现业务逻辑，生命周期和错误处理由基类提供
 *
 * 设计模式：
 * - 模板方法模式：定义算法骨架，子类实现具体步骤
 * - 策略模式：通过钩子方法让子类自定义行为
 * - 观察者模式：通过消息总线实现解耦通信
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.BasePlugin = void 0;
const log_1 = require("../log");
/**
 * 通用插件基类
 *
 * 职责：
 * - 实现插件的基本元数据管理
 * - 提供生命周期钩子的默认实现
 * - 提供消息订阅的辅助方法
 * - 提供通用的错误处理机制
 * - 简化子类实现
 */
class BasePlugin {
    constructor() {
        /**
         * 订阅 ID 集合（用于自动取消订阅）
         */
        this.subscriptionIds = new Set();
    }
    /**
     * 设置消息总线实例
     *
     * 由 PluginManager 在注册插件时调用
     * 插件通过这个 MessageBus 实例进行消息订阅和发布
     *
     * @param messageBus 消息总线实例
     */
    setMessageBus(messageBus) {
        this.messageBus = messageBus;
        log_1.logger.debug(`[Plugin ${this.name}] MessageBus injected`);
    }
    /**
     * 订阅消息
     *
     * 子类可以通过此方法订阅消息，订阅会在插件停用时自动取消
     *
     * 使用示例：
     * ```typescript
     * async onActivate() {
     *     // 订阅配置变更
     *     this.subscribeMessage('config:change', (msg) => {
     *         const config = msg.payload;
     *         this.updateConfig(config);
     *     });
     *
     *     // 订阅文件变更
     *     this.subscribeMessage('file:change', (msg) => {
     *         const filePath = msg.payload.filePath;
     *         this.handleFileChange(filePath);
     *     });
     * }
     * ```
     *
     * @param type 消息类型
     * @param handler 消息处理器
     * @param options 订阅选项
     * @returns 订阅 ID
     */
    subscribeMessage(type, handler, options) {
        if (!this.messageBus) {
            throw new Error(`[Plugin ${this.name}] MessageBus not initialized. Call setMessageBus() first.`);
        }
        const subscriptionId = this.messageBus.subscribe(type, handler, options);
        this.subscriptionIds.add(subscriptionId);
        log_1.logger.debug(`[Plugin ${this.name}] Subscribed to message type "${type}"`);
        return subscriptionId;
    }
    /**
     * 取消消息订阅
     *
     * 使用示例：
     * ```typescript
     * async onDeactivate() {
     *     this.unsubscribeMessage(this.configSubId);
     *     this.unsubscribeMessage(this.fileSubId);
     * }
     * ```
     *
     * @param subscriptionId 订阅 ID
     * @returns 是否成功取消
     */
    unsubscribeMessage(subscriptionId) {
        if (!this.messageBus) {
            log_1.logger.warn(`[Plugin ${this.name}] Message bus not available, cannot unsubscribe`);
            return false;
        }
        const success = this.messageBus.unsubscribe(subscriptionId);
        if (success) {
            this.subscriptionIds.delete(subscriptionId);
            log_1.logger.debug(`[Plugin ${this.name}] Unsubscribed message ${subscriptionId}`);
        }
        return success;
    }
    /**
     * 发布消息（简化 API）
     *
     * 快速发布消息到消息总线
     *
     * 使用示例：
     * ```typescript
     * await this.publish('task:complete', {
     *     taskId: '123',
     *     result: 'success',
     *     data: { // ... }
     * });
     * ```
     *
     * @param type 消息类型
     * @param payload 消息载荷
     * @param source 消息来源（可选）
     * @returns 处理该消息的订阅者数量
     */
    publish(type, payload, source) {
        if (!this.messageBus) {
            throw new Error(`[Plugin ${this.name}] MessageBus not initialized. Call setMessageBus() first.`);
        }
        const count = this.messageBus.publish(type, payload, source || this.name);
        log_1.logger.debug("[Plugin " +
            this.name +
            '] Published message type "' +
            type +
            '" to ' +
            count +
            " subscribers");
        return count;
    }
    /**
     * 发布消息（高级 API）
     *
     * 发布完整的 Message 对象，支持元数据
     *
     * 使用示例：
     * ```typescript
     * await this.publishMessage({
     *     type: 'task:complete',
     *     payload: {
     *         taskId: '123',
     *         result: 'success'
     *     },
     *     metadata: {
     *         duration: 1500,
     *         priority: 'high'
     *     }
     * });
     * ```
     *
     * @param message 消息对象（包含 type 和 payload 为必需）
     * @returns 处理该消息的订阅者数量
     */
    publishMessage(message) {
        if (!this.messageBus) {
            throw new Error(`[Plugin ${this.name}] MessageBus not initialized. Call setMessageBus() first.`);
        }
        const count = this.messageBus.publishMessage({
            ...message,
            source: message.source || this.name,
        });
        log_1.logger.debug("[Plugin " +
            this.name +
            '] Published message type "' +
            message.type +
            '"');
        return count;
    }
    /**
     * 发布生命周期事件
     *
     * 用于在特定的生命周期阶段发送通知
     * 通常由 PluginManager 调用，插件一般不需要直接使用
     *
     * @param eventType 事件类型（来自 PluginLifecycleEvents）
     * @param payload 事件载荷
     * @returns 处理该事件的订阅者数量
     */
    publishLifecycleEvent(eventType, payload) {
        return this.publishMessage({
            type: eventType,
            payload: {
                pluginName: this.name,
                timestamp: Date.now(),
                ...payload,
            },
        });
    }
    /**
     * 获取插件依赖声明
     *
     * 默认实现：无依赖
     * 子类可以重写此方法以声明依赖
     *
     * @returns 插件依赖数组
     */
    getDependencies() {
        return [];
    }
    /**
     * 获取插件提供的能力列表
     *
     * 默认实现：空列表
     * 子类可以重写此方法以声明能力
     *
     * @returns 能力列表
     */
    getCapabilities() {
        return [];
    }
    /**
     * 插件停用时的钩子（可选）
     *
     * 子类可以重写此方法以执行清理逻辑：
     * - 清理资源
     * - 取消事件监听器
     * - 断开外部服务
     * - 取消消息订阅
     *
     * 默认实现：取消所有消息订阅
     */
    async onDeactivate() {
        // 自动取消所有消息订阅
        for (const subscriptionId of this.subscriptionIds) {
            if (this.messageBus) {
                this.messageBus.unsubscribe(subscriptionId);
            }
        }
        this.subscriptionIds.clear();
    }
    /**
     * 获取插件元数据
     * @returns 插件元数据对象
     */
    getMetadata() {
        return {
            name: this.name,
            displayName: this.displayName,
            version: this.version,
            description: this.description,
        };
    }
    /**
     * 执行异步操作并捕获异常
     *
     * 辅助方法，用于简化异步操作的错误处理
     *
     * @param operation 要执行的异步操作
     * @param context 操作上下文（用于日志）
     * @returns 操作结果或 undefined（如果失败）
     */
    async safeExecute(operation, context) {
        try {
            return await operation();
        }
        catch (error) {
            log_1.logger.error(`${this.name}: ${context} failed: ${String(error)}`);
            return undefined;
        }
    }
    /**
     * 执行异步操作并返回默认值
     *
     * 辅助方法，用于简化异步操作的错误处理
     *
     * @param operation 要执行的异步操作
     * @param defaultValue 默认值（操作失败时返回）
     * @param context 操作上下文（用于日志）
     * @returns 操作结果或默认值
     */
    async safeExecuteWithDefault(operation, defaultValue, context) {
        try {
            return await operation();
        }
        catch (error) {
            log_1.logger.error(`${this.name}: ${context} failed, using default: ${String(error)}`);
            return defaultValue;
        }
    }
}
exports.BasePlugin = BasePlugin;
//# sourceMappingURL=base-plugin.js.map