"use strict";
/**
 * 插件模块 - 领域层
 *
 * 提供插件接口、基础实现和领域类型
 * 不依赖 VSCode，可在 CLI、Web、桌面应用等场景复用
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
__exportStar(require("../shared/performance-metrics"), exports);
__exportStar(require("./plugin-initializer"), exports);
__exportStar(require("./plugin-interface"), exports);
__exportStar(require("./plugin-manager"), exports);
__exportStar(require("./plugins/base-plugin"), exports);
__exportStar(require("./plugins/shellcheck-plugin"), exports);
__exportStar(require("./plugins/shfmt-plugin"), exports);
__exportStar(require("./port"), exports);
__exportStar(require("./types"), exports);
//# sourceMappingURL=index.js.map