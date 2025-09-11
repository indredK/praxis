import { Router, json, Request, Response } from "express";
import { REAL_DEVICE_IP } from "../config.js";
import http from "http";
import { URL } from "url";
import { apiMockRegistry } from "../mock_registries/api.mockRegistry.js";
import { findApiRule } from "./utils.js";
import _ from "lodash";
import { MockRule } from "../mock_registries/type.js";

const apiHandler = Router();

// 工具函数：代理请求并处理响应
function proxyRequest(
  req: Request,
  res: Response,
  matchedRule?: MockRule
) {
  const targetUrl = new URL(REAL_DEVICE_IP);

  const options: http.RequestOptions = {
    hostname: targetUrl.hostname,
    port: targetUrl.port || 80,
    path: req.originalUrl,
    method: req.method,
    headers: { ...req.headers, host: targetUrl.host },
  };

  const proxyReq = http.request(options, (proxyRes) => {
    // 如果命中修改器规则
    if (matchedRule?.modifier) {
      console.log("[API Handler] 命中“修改器”规则:", matchedRule.requestMatch);
      const bodyChunks: Buffer[] = [];

      proxyRes.on("data", (chunk) => bodyChunks.push(chunk));
      proxyRes.on("end", () => {
        const realDataString = Buffer.concat(bodyChunks).toString();

        try {
          const realData = JSON.parse(realDataString);
          const modifiedData = matchedRule.modifier!(_.cloneDeep(realData), req);

          const jsonData = JSON.stringify(modifiedData);
          res.writeHead(proxyRes.statusCode || 200, {
            ...proxyRes.headers,
            "Content-Type": "application/json",
            "Content-Length": Buffer.byteLength(jsonData),
          });
          res.end(jsonData);
        } catch (err) {
          console.error("[Modifier] 解析或修改响应失败，返回原始响应", err);
          res.writeHead(proxyRes.statusCode || 500, proxyRes.headers);
          res.end(realDataString);
        }
      });
    } else {
      // 普通代理转发
      console.log("[API Handler] 普通转发，无匹配规则。");
      res.writeHead(proxyRes.statusCode || 200, proxyRes.headers);
      proxyRes.pipe(res, { end: true });
    }
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

  if (matchedRule?.responseData) {
    // 路径 A：静态 Mock
    console.log("[API Handler] 命中静态 Mock 规则:", matchedRule.requestMatch);
    return res.json(matchedRule.responseData);
  }

  // 路径 B 或 C：代理（可能带 modifier）
  proxyRequest(req, res, matchedRule);
});

export { apiHandler };
