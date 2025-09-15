// /praxis/vitest.config.ts

import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // 1. 核心修正：告诉 Vitest 在哪里寻找测试文件
    // 这个 glob 模式会匹配 packages/ 目录下任何子目录中
    // 以 .test.ts 或 .spec.ts 结尾的文件
    include: ['packages/**/*.{test,spec}.ts'],

    // 2. (推荐) 为 UI 库等设置测试环境
    // 'jsdom' 模拟了一个浏览器环境，对于测试 React/Vue 组件是必需的
    environment: 'jsdom',

    // 3. (可选) 全局设置文件
    // 如果您有需要在所有测试前运行的设置脚本，可以在这里配置
    // setupFiles: './tests/setup.ts',
  },
});