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
    root: '.',

    // 查找所有 packages 目录下的测试文件
    include: ['packages/**/*.{test,spec}.{ts,tsx}'],
    
    // 排除无需测试的目录
    exclude: [
      '**/node_modules/**',
      '**/dist/**',
    ],

    // 启用全局 API (describe, it, etc.)
    globals: true,
    
    // 为 UI 测试设置 jsdom 环境
    environment: 'jsdom',
  },
});