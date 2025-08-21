// tsup.config.ts
import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src/index.ts'],      // 打包入口
  format: ['cjs', 'esm'],       // 输出 CommonJS 和 ES Module 两种格式
  dts: true,                    // 生成 .d.ts 类型定义文件
  splitting: false,
  sourcemap: true,
  clean: true,                  // 打包前清空 dist 目录
});