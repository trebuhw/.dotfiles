"use strict";
/**
 * 基础插件抽象类
 *
 * 职责：
 * - 继承通用插件机制 (BasePlugin)
 * - 提供格式化和检查功能的基础实现
 * - 提供统一的异常处理和错误转换机制
 * - 简化子类的实现，避免重复的 try-catch 和错误处理代码
 *
 * 设计模式：
 * 模板方法模式（Template Method Pattern）
 * - check() 和 format() 方法由子类实现
 * - 基类提供 handleCheckError() 和 handleFormatError() 处理异常
 * - 子类只需关注核心业务逻辑，异常处理委托给基类
 *
 * 架构说明：
 * - 使用领域类型（Document, Diagnostic, TextEdit 等），不依赖 VSCode
 * - 领域层保持纯净，不依赖基础设施和配置
 * - 通过构造函数注入依赖（依赖倒置原则）
 * - 支持在 CLI、Web、桌面应用等多种场景使用
 *
 * 继承关系：
 * BasePlugin (通用插件机制)
 *   └── BasePlugin (领域层 - 插件基类)
 *         ├── PureShfmtPlugin
 *         └── PureShellcheckPlugin
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.BasePlugin = void 0;
const log_1 = require("../../utils/log");
const base_plugin_1 = require("../../utils/plugin/base-plugin");
const plugin_interface_1 = require("../plugin-interface");
/**
 * 创建执行错误诊断（私有工具方法）
 * 用于捕获异常时生成诊断对象
 */
function createErrorDiagnostic(document, errorMessage, source) {
    const range = {
        start: { line: 0, character: 0 },
        end: { line: 0, character: 0 },
    };
    return {
        range,
        message: errorMessage,
        severity: plugin_interface_1.DiagnosticSeverity.Error,
        code: "execution-error",
        source,
    };
}
/**
 * 基础插件抽象类
 *
 * 继承 BasePlugin（通用插件机制），提供格式化和检查功能的基础实现
 * 使用领域类型，不依赖 VSCode、基础设施和配置
 */
class BasePlugin extends base_plugin_1.BasePlugin {
    /**
     * 获取插件的诊断源名称
     * 从注入的配置中获取
     */
    getDiagnosticSource() {
        return this.pluginConfig.diagnosticSource;
    }
    /**
     * 获取支持的文件扩展名
     * 从注入的配置中获取
     */
    getSupportedExtensions() {
        return this.pluginConfig.fileExtensions;
    }
    /**
     * 获取插件依赖
     * 格式化插件默认没有依赖
     */
    getDependencies() {
        return [];
    }
    /**
     * 获取插件能力
     * 返回此插件提供的能力
     */
    getCapabilities() {
        const extensions = this.getSupportedExtensions();
        return [
            `format:${this.name}`,
            `check:${this.name}`,
            `extensions:${extensions.join(",")}`,
        ];
    }
    /**
     * 处理 check 操作的异常
     *
     * @param document 文档对象（领域类型）
     * @param error 捕获到的异常
     * @returns PluginCheckResult（包含错误诊断）
     */
    handleCheckError(document, error) {
        const errorMessage = String(error);
        log_1.logger?.error(`${this.name}.check() error: ${errorMessage}`);
        return {
            hasErrors: true,
            diagnostics: [
                createErrorDiagnostic(document, errorMessage, this.getDiagnosticSource()),
            ],
        };
    }
    /**
     * 处理 format 操作的异常
     *
     * @param document 文档对象（领域类型）
     * @param error 捕获到的异常
     * @returns PluginFormatResult（包含错误诊断，没有 TextEdit）
     */
    handleFormatError(document, error) {
        const errorMessage = String(error);
        log_1.logger?.error(`${this.name}.format() error: ${errorMessage}`);
        return {
            hasErrors: true,
            diagnostics: [
                createErrorDiagnostic(document, errorMessage, this.getDiagnosticSource()),
            ],
            textEdits: [],
        };
    }
    /**
     * 创建格式化结果
     *
     * @param formattedContent 格式化后的内容
     * @param document 原始文档
     * @param diagnostics 诊断信息
     * @returns PluginFormatResult
     */
    createFormatResult(formattedContent, document, diagnostics) {
        const hasErrors = diagnostics.some((diag) => diag.severity === plugin_interface_1.DiagnosticSeverity.Error);
        // 生成 TextEdit（仅当无致命错误且内容有变化时）
        let textEdits = [];
        if (!hasErrors &&
            formattedContent &&
            formattedContent !== document.content) {
            textEdits = [
                {
                    range: {
                        start: { line: 0, character: 0 },
                        end: {
                            line: document.lineCount,
                            character: 0,
                        },
                    },
                    newText: formattedContent,
                },
            ];
        }
        return {
            hasErrors,
            diagnostics,
            textEdits,
        };
    }
}
exports.BasePlugin = BasePlugin;
//# sourceMappingURL=base-plugin.js.map