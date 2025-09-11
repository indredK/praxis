import { Router, json, Request, Response } from "express";
import { REAL_DEVICE_IP } from "../config.js";
import http from "http";
import { URL } from "url";
import { apiMockRegistry } from "../mock_registries/api.mockRegistry.js";
import { findApiRule } from "./utils.js"; // 确保导入的是正确的查找函数
import _ from "lodash";
import { MockRule } from "../mock_registries/type.js";

const apiHandler = Router();

// 工具函数：重构后的代理请求函数，现在它负责所有代理逻辑
function proxyRequest(req: Request, res: Response, matchedRule?: MockRule) {
  // 1. 在发起代理前，记录当前时间
  const startTime = Date.now();
  const targetUrl = new URL(REAL_DEVICE_IP);

  const options: http.RequestOptions = {
    hostname: targetUrl.hostname,
    port: targetUrl.port || 80,
    path: req.originalUrl,
    method: req.method,
    headers: { ...req.headers, host: targetUrl.host },
  };

  const proxyReq = http.request(options, (proxyRes) => {
    // 为了实现延迟，我们必须先将响应完整地缓存起来
    const bodyChunks: Buffer[] = [];
    proxyRes.on("data", (chunk) => bodyChunks.push(chunk));
    proxyRes.on("end", () => {
      // 2. 计算真实请求已经花费的时间
      const elapsedTime = Date.now() - startTime;

      // 将所有最终的响应逻辑包装在一个函数中
      const responseAction = () => {
        const realDataString = Buffer.concat(bodyChunks).toString();

        // 如果命中了 "修改器" 规则，则执行修改逻辑
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
          // 否则，执行最纯粹的“普通”代理转发
          res.writeHead(proxyRes.statusCode!, proxyRes.headers);
          res.end(realDataString); // 发送我们缓存的原始响应体
        }
      };

      // 3. 核心逻辑：计算并应用需要补充的延迟
      const desiredDelay = matchedRule?.delay || 0;
      const remainingDelay = Math.max(0, desiredDelay - elapsedTime);

      console.log(`[API 代理] 真实耗时: ${elapsedTime}ms, 目标总延迟: ${desiredDelay}ms, 将补充延迟: ${remainingDelay}ms`);

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

// 主逻辑
apiHandler.use("/api", json(), (req: Request, res: Response) => {
  console.log(`[API Handler] 接收到请求: ${req.method} ${req.originalUrl}`);

  const matchedRule = findApiRule(req, apiMockRegistry);

  // --- 路径 A：静态 Mock (应用简单延迟) ---
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

  // --- 路径 B 或 C：所有需要代理的请求（无论是否带修改器），都交给重构后的 proxyRequest 函数处理 ---
  proxyRequest(req, res, matchedRule);
});

export { apiHandler };