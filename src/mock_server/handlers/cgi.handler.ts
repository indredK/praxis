import express, { Router, Request, Response, NextFunction } from "express";
import { createProxyMiddleware } from "http-proxy-middleware";
import _ from "lodash";
import { MOCK_CGI_DATA, REAL_DEVICE_IP } from "../config.js";
import { mockRegistry } from "../mock_registries/cgi.mockRegistry.js";
import { findMatchingRule } from "./utils.js";
import { MockRule } from "../mock_registries/type.js";

const cgiHandler = Router();
const cgiBodyParser = express.text({ type: "application/x-www-form-urlencoded" });

// 工具函数：构建代理请求体
function writeProxyBody(proxyReq: any, body: string) {
  proxyReq.setHeader("Content-Length", Buffer.byteLength(body));
  proxyReq.write(body);
}

// 工具函数：处理代理响应并应用 modifier
function handleProxyResponse(
  proxyRes: any,
  res: Response,
  bodyString: string,
  modifier: NonNullable<MockRule["modifier"]>,
  req: Request
) {
  const bodyChunks: Buffer[] = [];
  proxyRes.on("data", (chunk: Buffer) => bodyChunks.push(chunk));

  proxyRes.on("end", () => {
    const realDataString = Buffer.concat(bodyChunks).toString();

    try {
      const realData = JSON.parse(realDataString);
      const modifiedData = modifier(_.cloneDeep(realData), req);

      res.status(proxyRes.statusCode || 200);
      Object.entries(proxyRes.headers).forEach(([key, value]) => {
        if (value !== undefined) res.setHeader(key, value as string);
      });

      res.json(modifiedData);
    } catch (err) {
      console.error("[Modifier] 解析真实设备响应失败", err);
      res.status(proxyRes.statusCode || 500).end(realDataString);
    }
  });
}

// 主逻辑
cgiHandler.post("/cgi", cgiBodyParser, (req: Request, res: Response, next: NextFunction) => {
  // 1. 全局 Mock 数据
  if (MOCK_CGI_DATA) {
    return res.status(200).json(MOCK_CGI_DATA);
  }

  // 2. 检查 body
  const bodyString = req.body;
  if (typeof bodyString !== "string" || bodyString.length === 0) {
    return next();
  }

  let payload: any;
  try {
    payload = JSON.parse(bodyString);
  } catch {
    return next();
  }

  const matchedRule = findMatchingRule(payload, mockRegistry as any);

  // 3. 命中修改器规则
  if (matchedRule?.modifier) {
    console.log("[CGI Handler] 命中“修改器”规则:", matchedRule.requestMatch);

    return createProxyMiddleware({
      target: REAL_DEVICE_IP,
      changeOrigin: true,
      selfHandleResponse: true,
      on: {
        proxyReq: (proxyReq) => writeProxyBody(proxyReq, bodyString),
        proxyRes: (proxyRes) => handleProxyResponse(proxyRes, res, bodyString, matchedRule.modifier!, req),
      },
    })(req, res, next);
  }

  // 4. 命中静态 Mock 规则
  if (matchedRule?.responseData) {
    console.log("[CGI Handler] 命中静态 Mock 规则:", matchedRule.requestMatch);
    return res.json(matchedRule.responseData);
  }

  // 5. 普通转发
  console.log("[CGI Handler] 未命中任何 Mock 规则，执行普通转发。");
  return createProxyMiddleware({
    target: REAL_DEVICE_IP,
    changeOrigin: true,
    on: {
      proxyReq: (proxyReq) => writeProxyBody(proxyReq, bodyString),
    },
  })(req, res, next);
});

export { cgiHandler };
