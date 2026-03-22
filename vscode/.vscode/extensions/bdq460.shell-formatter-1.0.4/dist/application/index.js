"use strict";
/**
 * Application 层导出
 *
 * 应用层职责：
 * - 用例编排（usecases/）
 * - 应用服务（services/）
 * - DI 初始化（di/）
 *
 * 依赖：domain/, shared/, utils/
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.showPluginStatus = exports.isPluginAvailable = exports.getAllPluginStatus = exports.PERFORMANCE_METRICS = exports.startTimer = exports.showPerformanceReport = exports.getPerformanceSummary = exports.getPerformanceStats = exports.checkPerformanceHealth = exports.formatDocument = exports.diagnoseDocument = exports.reinitializeDIContainer = exports.initializeDIContainer = void 0;
// DI 初始化
var initializer_1 = require("./di/initializer");
Object.defineProperty(exports, "initializeDIContainer", { enumerable: true, get: function () { return initializer_1.initializeDIContainer; } });
Object.defineProperty(exports, "reinitializeDIContainer", { enumerable: true, get: function () { return initializer_1.reinitializeDIContainer; } });
// Usecases
var diagnose_document_1 = require("./usecases/diagnose-document");
Object.defineProperty(exports, "diagnoseDocument", { enumerable: true, get: function () { return diagnose_document_1.diagnoseDocument; } });
var format_document_1 = require("./usecases/format-document");
Object.defineProperty(exports, "formatDocument", { enumerable: true, get: function () { return format_document_1.formatDocument; } });
// Services - Performance Service
var performance_service_1 = require("./services/performance-service");
Object.defineProperty(exports, "checkPerformanceHealth", { enumerable: true, get: function () { return performance_service_1.checkPerformanceHealth; } });
Object.defineProperty(exports, "getPerformanceStats", { enumerable: true, get: function () { return performance_service_1.getPerformanceStats; } });
Object.defineProperty(exports, "getPerformanceSummary", { enumerable: true, get: function () { return performance_service_1.getPerformanceSummary; } });
Object.defineProperty(exports, "showPerformanceReport", { enumerable: true, get: function () { return performance_service_1.showPerformanceReport; } });
Object.defineProperty(exports, "startTimer", { enumerable: true, get: function () { return performance_service_1.startTimer; } });
// Domain - Performance Metrics (re-export for convenience)
var performance_metrics_1 = require("../shared/performance-metrics");
Object.defineProperty(exports, "PERFORMANCE_METRICS", { enumerable: true, get: function () { return performance_metrics_1.PERFORMANCE_METRICS; } });
// Services - Plugin Status Service
var plugin_status_service_1 = require("./services/plugin-status-service");
Object.defineProperty(exports, "getAllPluginStatus", { enumerable: true, get: function () { return plugin_status_service_1.getAllPluginStatus; } });
Object.defineProperty(exports, "isPluginAvailable", { enumerable: true, get: function () { return plugin_status_service_1.isPluginAvailable; } });
Object.defineProperty(exports, "showPluginStatus", { enumerable: true, get: function () { return plugin_status_service_1.showPluginStatus; } });
//# sourceMappingURL=index.js.map