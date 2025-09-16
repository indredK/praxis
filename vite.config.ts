// /praxis/vite.config.ts

/// <reference types="vitest" />
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  // --- Vite 的配置 (用于 webapp) ---
  plugins: [react()],

  // --- Vitest 的配置 (唯一的测试配置来源) ---
  test: {
    // 明确指定项目的根目录
    // root: '.',

   // 这个是 Vitest 官方推荐的最全面的匹配模式
    include: ['**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}'],
    
    // 排除无需测试的目录
    exclude: [
      '**/node_modules/**',
      '**/dist/**',
    ],

    // 启用全局 API (describe, it, etc.)
    globals: true,
    
    // 为 UI 测试设置 jsdom 环境
    // environment: 'jsdom',
  },
});