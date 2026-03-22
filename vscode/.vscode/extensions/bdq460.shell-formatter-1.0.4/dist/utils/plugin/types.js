"use strict";
/**
 * 插件消息系统类型定义
 *
 * 定义消息订阅者模式的核心类型
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.PluginLifecycleEvents = void 0;
/**
 * 插件生命周期事件消息类型
 *
 * 用于插件激活和停用过程中的消息通信
 * 允许插件感知其他插件的生命周期变化
 */
exports.PluginLifecycleEvents = {
    /** 插件开始激活前（其他插件可以准备） */
    BEFORE_ACTIVATE: "plugin:before-activate",
    /** 插件激活成功后（其他插件可以响应） */
    ACTIVATED: "plugin:activated",
    /** 插件激活失败时 */
    ACTIVATION_FAILED: "plugin:activation-failed",
    /** 插件开始停用前（其他插件可以准备） */
    BEFORE_DEACTIVATE: "plugin:before-deactivate",
    /** 插件停用完成后 */
    DEACTIVATED: "plugin:deactivated",
    /** 插件停用失败时 */
    DEACTIVATION_FAILED: "plugin:deactivation-failed",
};
//# sourceMappingURL=types.js.map