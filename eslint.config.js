// For more info, see https://github.com/storybookjs/eslint-plugin-storybook#configuration-flat-config-format
import storybook from "eslint-plugin-storybook";

// /praxis/eslint.config.js

import globals from "globals";
import js from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(// 全局忽略文件
{
  ignores: [
    "**/node_modules/",
    "**/dist/",
    "**/.turbo/",
    "**/coverage/",
    "docs/",
  ],
}, // 基础配置，应用于所有 JS/TS 文件
js.configs.recommended, // TypeScript 专用配置
...tseslint.configs.recommended, // 自定义规则配置
{
  languageOptions: {
    ecmaVersion: "latest",
    sourceType: "module",
    globals: {
      ...globals.browser, // 如果您的代码会运行在浏览器环境
      ...globals.node,    // 如果您的代码会运行在 Node.js 环境
    },
  },
  rules: {
    "@typescript-eslint/no-explicit-any": "off",
    "@typescript-eslint/no-unused-vars": [
      "warn", // 或者 "error"，将级别设置为警告或错误
      {
        "args": "after-used",
        "argsIgnorePattern": "^_",
        "varsIgnorePattern": "^_",
        "caughtErrorsIgnorePattern": "^_"
      }
    ]
    // 在这里添加或覆盖您自己的规则
    // 例如：
    // "semi": ["error", "always"],
    // "@typescript-eslint/no-unused-vars": "warn"
  },
}, storybook.configs["flat/recommended"]);