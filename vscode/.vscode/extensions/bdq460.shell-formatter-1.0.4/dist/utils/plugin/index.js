"use strict";
/**
 * 通用插件机制
 *
 * 提供不依赖任何外部框架的插件基础设施
 * 可用于 CLI、Web、桌面应用等各种场景
 *
 * 目录结构：
 * - IPlugin.ts: 通用插件接口
 * - BasePlugin.ts: 通用插件基类
 * - PluginManager.ts: 通用插件管理器
 * - MessageBus.ts: 消息总线（发布-订阅模式）
 * - types.ts: 类型定义和常量
 *
 * 核心特性：
 * - 插件生命周期管理（通过消息驱动）
 * - 消息订阅者模式（解耦通信）
 * - 完整的错误处理和生命周期事件
 * - 灵活的消息过滤和优先级
 * - 依赖管理和能力声明
 *
 * 生命周期事件：
 * - plugin:before-activate - 激活前（允许准备）
 * - plugin:activated - 激活成功（附带能力列表）
 * - plugin:activation-failed - 激活失败（附带错误信息）
 * - plugin:before-deactivate - 停用前（允许准备）
 * - plugin:deactivated - 停用成功
 * - plugin:deactivation-failed - 停用失败（附带错误信息）
 *
 * 使用示例：
 * ```typescript
 * import {
 *     BasePlugin,
 *     PluginManager,
 *     PluginLifecycleEvents,
 *     PluginDependency
 * } from '@/utils/plugin';
 *
 * class MyPlugin extends BasePlugin {
 *     get name() { return 'my-plugin'; }
 *     get displayName() { return 'My Plugin'; }
 *     get version() { return '1.0.0'; }
 *     get description() { return 'My plugin'; }
 *
 *     async isAvailable() { return true; }
 *
 *     getDependencies(): PluginDependency[] {
 *         return [
 *             { name: 'config-plugin', required: true }
 *         ];
 *     }
 *
 *     getCapabilities(): string[] {
 *         return ['format', 'check'];
 *     }
 *
 *     async onActivate() {
 *         // 订阅配置变更消息
 *         this.subscribeMessage('config:change', (msg) => {
 *             const config = msg.payload;
 *             this.updateConfig(config);
 *         });
 *
 *         // 监听其他插件激活
 *         this.subscribeMessage(PluginLifecycleEvents.ACTIVATED, (msg) => {
 *             console.log(`Plugin ${msg.payload.pluginName} activated`);
 *         });
 *
 *         // 发布消息（简化 API）
 *         await this.publish('plugin:ready', {
 *             plugin: this.name,
 *             capabilities: this.getCapabilities()
 *         });
 *
 *         // 发布消息（高级 API，支持元数据）
 *         await this.publishMessage({
 *             type: 'task:complete',
 *             payload: { taskId: '123' },
 *             metadata: { duration: 1500 }
 *         });
 *     }
 *
 *     async onDeactivate() {
 *         // 自动取消所有消息订阅（由基类处理）
 *         console.log('Plugin deactivating...');
 *     }
 * }
 *
 * // 创建插件管理器
 * const manager = new PluginManager();
 * manager.register(new MyPlugin());
 *
 * // 激活插件（会自动发送生命周期消息）
 * await manager.activate('my-plugin');
 *
 * // 发布消息到所有订阅者
 * const messageBus = manager.getMessageBus();
 * await messageBus.publish('config:update', { indent: 4 });
 *
 * // 或使用高级 API 发布完整 Message
 * await messageBus.publishMessage({
 *     type: 'config:update',
 *     payload: { indent: 4 },
 *     metadata: { source: 'settings' }
 * });
 * ```
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
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
__exportStar(require("./base-plugin"), exports);
__exportStar(require("./plugin-interface"), exports);
__exportStar(require("./message-bus"), exports);
__exportStar(require("./plugin-manager"), exports);
__exportStar(require("./types"), exports);
//# sourceMappingURL=index.js.map