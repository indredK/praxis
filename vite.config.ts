// vite.config.ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],

  // ⬇️ 替换您的 test 配置 ⬇️
  test: {
    // 引用我们刚刚创建的两个独立的测试项目配置文件
    projects: ["./vitest.unit.config.ts", "./vitest.storybook.config.ts"],
  },
});
