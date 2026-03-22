"use strict";
/**
 * Shell Formatter VSCode Extension
 * 基于 shfmt 和 shellcheck 的 Shell 脚本格式化插件
 *
 * 架构说明：
 * - entrypoints 层：直接与 VSCode API 交互，注册 Provider、监听器和命令
 * - features 层：实现业务逻辑
 * - extension.ts：作为入口，负责初始化和协调各层
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
exports.activate = activate;
exports.deactivate = deactivate;
const vscode = __importStar(require("vscode"));
const application_1 = require("./application");
const config_1 = require("./config");
const plugin_initializer_1 = require("./domain/plugin-initializer");
const entrypoints = __importStar(require("./entrypoints"));
const i18n_1 = require("./i18n");
const logger_1 = require("./shared/logger");
const debounce_1 = require("./utils/debounce");
const container_1 = require("./utils/di/container");
const log_1 = require("./utils/log");
// ==================== 防抖管理器 ====================
const debounceManager = new debounce_1.DebounceManager();
/**
 * 扩展激活函数
 */
async function activate(context) {
    // 初始化日志
    console.log(`[${config_1.PackageInfo.extensionName}] Start initialize logger`);
    // 初始化日志
    (0, logger_1.initializeLogger)();
    log_1.logger.info("Extension is now active");
    // 初始化 i18n
    log_1.logger.info("Initializing i18n");
    const languageSetting = config_1.SettingInfo.getLanguage();
    (0, i18n_1.initializeI18n)(languageSetting);
    // 初始化 DI 容器
    log_1.logger.info("Initializing DI container");
    const container = (0, container_1.getContainer)();
    (0, application_1.initializeDIContainer)(container);
    // 初始化插件（等待插件激活完成）
    log_1.logger.info("Initializing plugins from DI container");
    await (0, plugin_initializer_1.initializePlugins)();
    // 创建诊断集合
    const diagnosticCollection = entrypoints.createDiagnosticCollection();
    // 注册所有 VSCode 功能（使用 entrypoints 层）
    const disposables = [
        // 格式化提供者
        entrypoints.registerFormattingProvider(),
        // Code Actions 提供者
        entrypoints.registerCodeActionsProvider(diagnosticCollection),
        // 所有命令
        ...entrypoints.registerAllCommands(diagnosticCollection),
        // 文档监听器
        entrypoints.registerSaveListener(diagnosticCollection, debounceManager),
        entrypoints.registerOpenListener(diagnosticCollection),
        entrypoints.registerChangeListener(diagnosticCollection, debounceManager),
        entrypoints.registerCloseListener(diagnosticCollection, debounceManager),
        entrypoints.registerDeleteListener(diagnosticCollection),
        entrypoints.registerConfigChangeListener(diagnosticCollection, debounceManager),
    ];
    // 将所有资源添加到上下文订阅中
    context.subscriptions.push(...disposables, diagnosticCollection);
}
/**
 * 扩展停用函数
 *
 * 清理说明：
 * - context.subscriptions 中的资源由 VSCode 自动清理
 * - debounceManager 中的定时器需要手动清理
 * - logger 需要手动清理
 * - DI 容器需要显式清理（如果实现了清理钩子）
 */
function deactivate() {
    log_1.logger.info("Extension is now deactivated");
    try {
        // 清理所有防抖定时器
        const activeCount = debounceManager.getActiveCount();
        log_1.logger.info(`Clearing ${activeCount} active debounce timers`);
        debounceManager.clearAll();
        // 清理 DI 容器（执行清理钩子）
        log_1.logger.info("Cleaning up DI container");
        const container = (0, container_1.getContainer)();
        if (container instanceof Object && "cleanup" in container) {
            container.cleanup();
        }
        // 清理日志输出通道
        if (log_1.logger instanceof vscode.Disposable) {
            log_1.logger.dispose();
        }
        log_1.logger.info("Deactivation completed successfully");
    }
    catch (error) {
        console.error(`Error during deactivation: ${String(error)}`);
    }
}
//# sourceMappingURL=extension.js.map