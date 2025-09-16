// /packages/mock-server/src/server.ts

import express, { Express, Request, Response, NextFunction } from "express";
import cors from "cors";
import chalk from "chalk";
import { MOCK_SERVER_PORT, REAL_DEVICE_IP } from "../config.js";

// --- 依赖注入的关键步骤 ---
// 1. 导入所有需要的“原材料”（开发态的 Mock 数据）
import { cgiMockRegistry } from "./mock_registries/cgi.mockRegistry.js";
import { apiMockRegistry } from "./mock_registries/api.mockRegistry.js";

// 2. 关键变化：不再导入每个独立的 handler 工厂，只导入“总组装工厂”
import { createRequestHandlers } from "./handlers/index.js";
import { normalizeUrl } from "./utils/url.js";

// --- 应用设置 ---
const app: Express = express();
app.use(cors());
app.use(express.json());

// --- 组装和挂载路由处理器 ---
// 3. 调用“总组装工厂”，一次性传入所有依赖
const requestHandlers = createRequestHandlers({
  cgiRegistry: cgiMockRegistry,
  apiRegistry: apiMockRegistry,
  proxyTarget: normalizeUrl(REAL_DEVICE_IP),
});

// 4. 将组装好的处理器责任链一次性应用到 app 上
app.use(...requestHandlers);

// --- 错误处理与 404 ---
// 添加一个 404 Not Found 处理器
app.use((req: Request, res: Response) => {
  res.status(404).json({
    error: "Not Found",
    message: `无法找到资源: ${req.method} ${req.originalUrl}`,
  });
});

// 添加一个通用的错误处理器
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error(chalk.red("[全局错误捕获]"), err.stack);
  res.status(500).json({
    error: "Internal Server Error",
    message: err.message,
  });
});

// --- 启动服务器 ---
// 只有在非测试环境下才启动监听
if (process.env.NODE_ENV !== "test") {
  app.listen(MOCK_SERVER_PORT, () => {
    console.log(chalk.green("✅ --- Mock/Proxy Server (依赖注入版) 启动成功 --- ✅"));
    console.log(chalk.blue(`   🔗 监听端口: http://localhost:${MOCK_SERVER_PORT}`));
    console.log(chalk.yellow("   💡 使用开发态 Mock 数据"));
  });
}

// 导出 app 实例，以便测试文件可以导入和使用
export { app };
