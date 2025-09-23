import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react"; // 导入 react 插件

export default defineConfig({
  // ✅ 同样，plugins 数组在顶层
  plugins: [react()],
  test: {
    name: "unit",
    globals: true,
    // 为 UI 测试设置 jsdom 环境
    environment: "jsdom",
    include: ["**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}"],
    exclude: ["**/node_modules/**", "**/dist/**", "**/*.stories.{js,jsx,ts,tsx}"],
    setupFiles: ["./vitest.setup.ts"],
  },
});
