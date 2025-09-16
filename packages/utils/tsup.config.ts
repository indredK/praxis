// /packages/utils/tsup.config.ts

import { defineConfig } from 'tsup';

export default defineConfig({
  // 入口文件
  entry: ['index.ts'],

  // 输出格式
  format: ['cjs', 'esm'],
  
  // 生成类型声明文件
  dts: true,

  // 代码分割（对于库来说，通常建议关闭）
  splitting: false,

  // sourcemap
  sourcemap: true,

  // 在构建前清理 dist 目录
  clean: true,
});