// vite.config.ts

/// <reference types="vitest" />
import { defineConfig } from 'vite';

export default defineConfig({
  // ... 你的其他 Vite 配置

  test: {
    // 启用类似 jest 的全局 API
    globals: true,
    // 你还可以包含或排除特定的测试文件
    include: ['tests/**/*.test.ts'],
    // 如果你的代码依赖于 DOM API (例如 window, document)
    // environment: 'jsdom', 
  },
});