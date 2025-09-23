import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react"; // 导入 react 插件
import { storybookTest } from "@storybook/addon-vitest/vitest-plugin";
import path from "node:path";
import { fileURLToPath } from "node:url";

const dirname = typeof __dirname !== "undefined" ? __dirname : path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  // ✅ 关键修正：`plugins` 数组必须在顶层，与 `test` 对象平级
  plugins: [
    // Storybook 的 stories 文件是 React 组件，所以需要 react() 插件来解析 JSX
    react(),
    // Storybook 的测试插件
    storybookTest({
      configDir: path.join(dirname, ".storybook"),
    }),
  ],

  // `test` 对象只包含 Vitest 自己的配置
  test: {
    name: "storybook",
    globals: true,
    browser: {
      enabled: true,
      headless: true,
      provider: "playwright",
      name: "chromium",
    },
    // Storybook 测试有自己的 setup 文件
    setupFiles: [".storybook/vitest.setup.ts"],
  },
});
