"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DebounceManager = void 0;
/**
 * 防抖管理器
 * 管理多个文档的防抖定时器
 */
class DebounceManager {
    constructor() {
        this.timers = new Map();
    }
    /**
     * 设置防抖定时器
     * @param key 唯一键（文档 URI）
     * @param callback 回调函数
     * @param delay 延迟时间（毫秒）
     */
    debounce(key, callback, delay = 300) {
        // 清除旧定时器
        this.cancel(key);
        // 设置新定时器
        const timer = setTimeout(() => {
            try {
                callback();
            }
            finally {
                this.timers.delete(key);
            }
        }, delay);
        this.timers.set(key, timer);
    }
    /**
     * 取消特定键的防抖
     * @param key 唯一键
     */
    cancel(key) {
        const timer = this.timers.get(key);
        if (timer) {
            clearTimeout(timer);
            this.timers.delete(key);
        }
    }
    /**
     * 清除所有定时器
     */
    clearAll() {
        for (const timer of this.timers.values()) {
            clearTimeout(timer);
        }
        this.timers.clear();
    }
    /**
     * 获取活跃的定时器数量
     */
    getActiveCount() {
        return this.timers.size;
    }
}
exports.DebounceManager = DebounceManager;
//# sourceMappingURL=debounce.js.map