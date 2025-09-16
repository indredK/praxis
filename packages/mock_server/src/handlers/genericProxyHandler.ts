// /packages/mock-server/src/handlers/genericProxyHandler.ts

import { Router } from "express";
import { createProxyMiddleware, Options } from "http-proxy-middleware";
import { Response, Request } from "express";

interface ProxyHandlerDependencies {
  target: string;
}

export function createGenericProxyHandler(dependencies: ProxyHandlerDependencies): Router {
  const { target } = dependencies;
  const router = Router();

  const options: Options = {
    target,
    changeOrigin: true,
    on: {
      proxyRes: (proxyRes, req, res) => {
        console.log(`[通用代理] 路径: ${req.url}, 收到响应码:`, proxyRes.statusCode);
      },
      error: (err, req, res) => {
        console.error(`[通用代理错误] 路径: ${req.url}`, err);
        if (!(res as Response).headersSent) {
          (res as Response).status(502).send("Proxy Error");
        }
      },
    },
  };

  const proxyMiddleware = createProxyMiddleware(options);

  // 关键：在 Router 内部使用这个中间件，它会捕获所有到达这个 Router 的请求
  router.use(proxyMiddleware);

  return router;
}
