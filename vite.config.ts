/// <reference types="vitest/config" />
// /praxis/vite.config.ts

/// <reference types="vitest" />
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { storybookTest } from '@storybook/addon-vitest/vitest-plugin';
const dirname = typeof __dirname !== 'undefined' ? __dirname : path.dirname(fileURLToPath(import.meta.url));

// More info at: https://storybook.js.org/docs/next/writing-tests/integrations/vitest-addon
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
    exclude: ['**/node_modules/**', '**/dist/**'],
    // 启用全局 API (describe, it, etc.)
    globals: true

    // 为 UI 测试设置 jsdom 环境
    // environment: 'jsdom',
    ,
    projects: [{
      extends: true,
      plugins: [
      // The plugin will run tests for the stories defined in your Storybook config
      // See options at: https://storybook.js.org/docs/next/writing-tests/integrations/vitest-addon#storybooktest
      storybookTest({
        configDir: path.join(dirname, '.storybook')
      })],
      test: {
        name: 'storybook',
        browser: {
          enabled: true,
          headless: true,
          provider: 'playwright',
          instances: [{
            browser: 'chromium'
          }]
        },
        setupFiles: ['.storybook/vitest.setup.ts']
      }
    }]
  }
});