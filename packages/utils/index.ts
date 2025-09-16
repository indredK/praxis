// src/index.ts

/**
 * =================================================================
 * ✨ my-utils-library ✨
 * =================================================================
 * This is the main entry point for the library.
 * It exports all the public utility functions.
 *
 * 这 B C个文件是库的主入口文件，负责导出所有公开的工具函数。
 */

// --- 异步与流程控制 (Async & Control Flow) ---
export * from './src/asyncDebounce';
export * from './src/onceAsyncWithReset';
export * from './src/pLimit';
export * from './src/promisify';
export * from './src/timeout';

// --- 数据处理 (Data Manipulation) ---
export * from './src/flat';
export * from './src/mergeObjects';

// --- 函数式编程 (Functional Programming) ---
export * from './src/curry';

// --- i18n 相关工具 (i18n Utilities) ---
// 注意: 导出 .js 文件需要您 tsconfig.json 中的 `allowJs` 选项为 true
// export * from './utils/i18n-utils/excel_to_js.js';
// export * from './utils/i18n-utils/js_to_excel.js';