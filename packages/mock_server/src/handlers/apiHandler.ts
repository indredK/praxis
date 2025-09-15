// /packages/mock-server/src/handlers/apiHandler.ts

import { Router, json, Request, Response } from "express";
import http from "http";
import { URL } from "url";
import _ from "lodash";
// 1. 不再直接导入 apiMockRegistry
// import { apiMockRegistry } from "../mock_registries/api.mockRegistry.js";
import { findApiRule } from "./utils.js";
import { MockRule } from "../type.js";

// 定义依赖接口
interface ApiHandlerDependencies {
  registry: MockRule[];
  proxyTarget: string;
}

// 2. 创建并导出工厂函数，它接收 registry 作为参数
export function createApiHandler({ registry, proxyTarget }: ApiHandlerDependencies): Router {
  const apiHandler = Router();

  // --- 您的所有内部工具函数和业务逻辑保持原样 ---
  function proxyRequest(req: Request, res: Response, matchedRule?: MockRule) {
    const startTime = Date.now();
    const targetUrl = new URL(proxyTarget);

    const options: http.RequestOptions = {
      hostname: targetUrl.hostname,
      port: targetUrl.port || 80,
      path: req.originalUrl,
      method: req.method,
      headers: { ...req.headers, host: targetUrl.host },
    };

    const proxyReq = http.request(options, (proxyRes) => {
      const bodyChunks: Buffer[] = [];
      proxyRes.on("data", (chunk) => bodyChunks.push(chunk));
      proxyRes.on("end", () => {
        const elapsedTime = Date.now() - startTime;
        const responseAction = () => {
          const realDataString = Buffer.concat(bodyChunks).toString();
          if (matchedRule?.modifier) {
            try {
              const realData = JSON.parse(realDataString);
              const modifiedData = matchedRule.modifier(_.cloneDeep(realData), req);
              const finalStatusCode = matchedRule.statusCode || proxyRes.statusCode || 200;
              const newBody = JSON.stringify(modifiedData);

              res.writeHead(finalStatusCode, {
                ...proxyRes.headers,
                "Content-Type": "application/json",
                "Content-Length": Buffer.byteLength(newBody),
              });
              res.end(newBody);
            } catch (err) {
              console.error("[Modifier] 解析或修改响应失败，返回原始响应", err);
              res.writeHead(proxyRes.statusCode || 500, proxyRes.headers).end(realDataString);
            }
          } else {
            res.writeHead(proxyRes.statusCode!, proxyRes.headers);
            res.end(realDataString);
          }
        };
        const desiredDelay = matchedRule?.delay || 0;
        const remainingDelay = Math.max(0, desiredDelay - elapsedTime);
        console.log(
          `[API 代理] 真实耗时: ${elapsedTime}ms, 目标总延迟: ${desiredDelay}ms, 将补充延迟: ${remainingDelay}ms`
        );
        if (remainingDelay > 0) {
          setTimeout(responseAction, remainingDelay);
        } else {
          responseAction();
        }
      });
    });

    proxyReq.on("error", (err) => {
      console.error("[原生代理] 请求转发错误:", err);
      if (!res.headersSent) res.status(502).send("Bad Gateway");
      res.end();
    });

    req.pipe(proxyReq, { end: true });
  }

  // --- 您的主逻辑保持原样 ---
  apiHandler.use("/api", json(), (req: Request, res: Response) => {
    console.log(`[API Handler] 接收到请求: ${req.method} ${req.originalUrl}`);

    // 3. 使用传入的 registry 参数
    const matchedRule = findApiRule(req, registry);

    if (matchedRule?.responseData) {
      console.log("[API Handler] 命中静态 Mock 规则:", matchedRule.requestMatch);
      const responseAction = () => {
        const finalStatusCode = matchedRule.statusCode || 200;
        console.log(`[API Handler] 返回静态 Mock, 状态码: ${finalStatusCode}, 延迟: ${matchedRule.delay || 0}ms`);
        res.status(finalStatusCode).json(matchedRule.responseData);
      };
      const delay = matchedRule.delay || 0;
      if (delay > 0) {
        setTimeout(responseAction, delay);
      } else {
        responseAction();
      }
      return;
    }

    proxyRequest(req, res, matchedRule);
  });

  // 4. 函数最后返回配置好的 apiHandler 实例
  return apiHandler;
}

// 5. 不再直接导出 apiHandler 实例
// export { apiHandler };
