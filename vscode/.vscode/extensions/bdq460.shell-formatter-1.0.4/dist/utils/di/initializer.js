"use strict";
/**
 * DI 容器初始化器接口
 *
 * 职责：
 * - 定义服务名称常量（纯常量，无依赖）
 * - 提供初始化函数类型定义
 *
 * 注意：utils/ 层不依赖外部模块，实际的初始化逻辑在其他层实现
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.ServiceNames = void 0;
/**
 * 服务名称常量
 * 集中管理所有服务名称，避免硬编码
 */
exports.ServiceNames = {
    // 基础设施层
    SHFMT_TOOL: "shfmtTool",
    SHELLCHECK_TOOL: "shellcheckTool",
    // 领域层
    PLUGIN_MANAGER: "pluginManager",
    SHFMT_PLUGIN: "shfmtPlugin",
    SHELLCHECK_PLUGIN: "shellcheckPlugin",
    // 应用层服务
    PERFORMANCE_SERVICE: "performanceService",
    PLUGIN_STATUS_SERVICE: "pluginStatusService",
};
//# sourceMappingURL=initializer.js.map