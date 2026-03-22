"use strict";
/**
 * 国际化（i18n）模块
 *
 * 功能：
 * - 自动检测 VSCode 语言设置
 * - 根据语言加载对应的语言包
 * - 提供字符串翻译功能
 * - 支持参数化翻译
 * - 语言包加载失败回退机制
 *
 * 支持语言：
 * - en: English
 * - zh: 简体中文
 * - zh-tw: 繁體中文
 * - ja: 日本語
 * - ko: 한국어
 * - de: Deutsch
 * - fr: Français
 * - es: Español
 * - ar: العربية
 * - vi: Tiếng Việt
 * - hi: हिन्दी
 * - ru: Русский
 * - pt: Português
 * - it: Italiano
 * - tr: Türkçe
 * - pl: Polski
 * - th: ไทย
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.initializeI18n = initializeI18n;
exports.getCurrentLocale = getCurrentLocale;
exports.getSupportedLocales = getSupportedLocales;
exports.t = t;
exports.setLocale = setLocale;
exports.isLocaleSupported = isLocaleSupported;
const vscode = __importStar(require("vscode"));
const log_1 = require("../utils/log");
// 导入所有语言包
const ar_json_1 = __importDefault(require("./locales/ar.json"));
const de_json_1 = __importDefault(require("./locales/de.json"));
const en_json_1 = __importDefault(require("./locales/en.json"));
const es_json_1 = __importDefault(require("./locales/es.json"));
const fr_json_1 = __importDefault(require("./locales/fr.json"));
const hi_json_1 = __importDefault(require("./locales/hi.json"));
const it_json_1 = __importDefault(require("./locales/it.json"));
const ja_json_1 = __importDefault(require("./locales/ja.json"));
const ko_json_1 = __importDefault(require("./locales/ko.json"));
const pl_json_1 = __importDefault(require("./locales/pl.json"));
const pt_json_1 = __importDefault(require("./locales/pt.json"));
const ru_json_1 = __importDefault(require("./locales/ru.json"));
const th_json_1 = __importDefault(require("./locales/th.json"));
const tr_json_1 = __importDefault(require("./locales/tr.json"));
const vi_json_1 = __importDefault(require("./locales/vi.json"));
const zh_tw_json_1 = __importDefault(require("./locales/zh-tw.json"));
const zh_json_1 = __importDefault(require("./locales/zh.json"));
/**
 * 语言包映射
 */
const localeMessages = {
    en: en_json_1.default,
    zh: zh_json_1.default,
    "zh-tw": zh_tw_json_1.default,
    ja: ja_json_1.default,
    ko: ko_json_1.default,
    de: de_json_1.default,
    fr: fr_json_1.default,
    es: es_json_1.default,
    ar: ar_json_1.default,
    vi: vi_json_1.default,
    hi: hi_json_1.default,
    ru: ru_json_1.default,
    pt: pt_json_1.default,
    it: it_json_1.default,
    tr: tr_json_1.default,
    pl: pl_json_1.default,
    th: th_json_1.default,
};
/**
 * 语言代码映射（处理变体）
 */
const localeMapping = {
    // 英语
    "en": "en",
    "en-US": "en",
    "en-GB": "en",
    // 简体中文
    "zh": "zh",
    "zh-CN": "zh",
    "zh-Hans": "zh",
    // 繁体中文
    "zh-TW": "zh-tw",
    "zh-HK": "zh-tw",
    "zh-MO": "zh-tw",
    "zh-Hant": "zh-tw",
    // 日语
    "ja": "ja",
    "ja-JP": "ja",
    // 韩语
    "ko": "ko",
    "ko-KR": "ko",
    // 德语
    "de": "de",
    "de-DE": "de",
    // 法语
    "fr": "fr",
    "fr-FR": "fr",
    // 西班牙语
    "es": "es",
    "es-ES": "es",
    // 阿拉伯语
    "ar": "ar",
    "ar-SA": "ar",
    // 越南语
    "vi": "vi",
    "vi-VN": "vi",
    // 印地语
    "hi": "hi",
    "hi-IN": "hi",
    // 俄语
    "ru": "ru",
    "ru-RU": "ru",
    // 葡萄牙语
    "pt": "pt",
    "pt-BR": "pt",
    "pt-PT": "pt",
    // 意大利语
    "it": "it",
    "it-IT": "it",
    "it-CH": "it",
    // 土耳其语
    "tr": "tr",
    "tr-TR": "tr",
    // 波兰语
    "pl": "pl",
    "pl-PL": "pl",
    // 泰语
    "th": "th",
    "th-TH": "th",
};
/**
 * 当前使用的语言
 */
let currentLocale = "en";
/**
 * 回退语言（当当前语言包加载失败时使用）
 */
const fallbackLocale = "en";
/**
 * 检测 VSCode 当前语言
 *
 * @returns 检测到的语言代码
 */
function detectLocale() {
    const vscodeLocale = vscode.env.language;
    // 尝试精确匹配
    if (localeMapping[vscodeLocale]) {
        return localeMapping[vscodeLocale];
    }
    // 尝试前缀匹配（如 "en-US" -> "en"）
    const baseLocale = vscodeLocale.split("-")[0];
    if (localeMapping[baseLocale]) {
        return localeMapping[baseLocale];
    }
    // 默认使用英文
    return "en";
}
/**
 * 获取语言包
 *
 * @param locale 语言代码
 * @returns 语言包对象
 */
function getLocaleMessages(locale) {
    const messages = localeMessages[locale];
    if (!messages) {
        log_1.logger.warn(`[i18n] Locale "${locale}" not found, falling back to "${fallbackLocale}"`);
        return localeMessages[fallbackLocale];
    }
    return messages;
}
/**
 * 初始化 i18n 模块
 *
 * @param configLanguage 配置的语言设置，'local' 表示自动检测 VSCode 语言
 */
function initializeI18n(configLanguage = "local") {
    if (configLanguage === "local") {
        // 自动检测 VSCode 语言
        currentLocale = detectLocale();
    }
    else {
        // 使用配置的语言
        if (localeMapping[configLanguage]) {
            currentLocale = localeMapping[configLanguage];
        }
        else if (isLocaleSupported(configLanguage)) {
            currentLocale = configLanguage;
        }
        else {
            log_1.logger.warn(`[i18n] Unsupported language "${configLanguage}", falling back to "en"`);
            currentLocale = "en";
        }
    }
    log_1.logger.info(`[i18n] Initialized with locale: ${currentLocale} (config: ${configLanguage})`);
}
/**
 * 获取当前语言
 *
 * @returns 当前语言代码
 */
function getCurrentLocale() {
    return currentLocale;
}
/**
 * 获取所有支持的语言
 *
 * @returns 支持的语言代码数组
 */
function getSupportedLocales() {
    return Object.keys(localeMessages);
}
/**
 * 翻译字符串（支持参数化）
 *
 * 使用方式：
 * - t("messages.noActiveDocument")
 * - t("messages.partialFixSuccess", { count: 5, remaining: 2 })
 *
 * @param key 翻译键（使用点号分隔路径）
 * @param params 可选的参数对象
 * @returns 翻译后的字符串
 */
function t(key, params) {
    const messages = getLocaleMessages(currentLocale);
    // 解析键路径（例如："common.enabled"）
    const keys = key.split(".");
    let value = messages;
    // 遍历路径获取值
    for (const k of keys) {
        if (value && typeof value === "object" && k in value) {
            value = value[k];
        }
        else {
            // 键不存在，尝试从回退语言获取
            const fallbackMessages = getLocaleMessages(fallbackLocale);
            let fallbackValue = fallbackMessages;
            for (const fk of keys) {
                if (fallbackValue && typeof fallbackValue === "object" && fk in fallbackValue) {
                    fallbackValue = fallbackValue[fk];
                }
                else {
                    log_1.logger.warn(`[i18n] Translation key not found: ${key}`);
                    return key;
                }
            }
            value = fallbackValue;
            break;
        }
    }
    // 确保值是字符串
    if (typeof value !== "string") {
        log_1.logger.warn(`[i18n] Translation value is not a string: ${key}`);
        return key;
    }
    // 替换参数（例如："Hello {name}" -> "Hello World"）
    if (params) {
        return value.replace(/\{(\w+)\}/g, (match, paramKey) => {
            const paramValue = params[paramKey];
            return paramValue !== undefined ? String(paramValue) : match;
        });
    }
    return value;
}
/**
 * 切换语言（用于测试或手动切换）
 *
 * @param locale 新的语言代码
 * @returns 是否切换成功
 */
function setLocale(locale) {
    if (!localeMessages[locale]) {
        log_1.logger.warn(`[i18n] Cannot set locale "${locale}": not supported`);
        return false;
    }
    currentLocale = locale;
    log_1.logger.info(`[i18n] Locale switched to: ${locale}`);
    return true;
}
/**
 * 检查是否支持指定语言
 *
 * @param locale 语言代码
 * @returns 是否支持
 */
function isLocaleSupported(locale) {
    return locale in localeMessages;
}
//# sourceMappingURL=index.js.map