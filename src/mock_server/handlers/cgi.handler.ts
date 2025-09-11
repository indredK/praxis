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
  if (body) {
    proxyReq.setHeader("Content-Length", Buffer.byteLength(body));
    proxyReq.write(body);
  }
}

// 工具函数：处理代理响应，并应用“智能延迟”和修改器
function handleModifierResponse(
  proxyRes: any,
  res: Response,
  matchedRule: MockRule,
  req: Request,
  // 关键1: 传入请求开始的时间戳
  startTime: number
) {
  const bodyChunks: Buffer[] = [];
  proxyRes.on("data", (chunk: Buffer) => bodyChunks.push(chunk));
  proxyRes.on("end", () => {
    // 2. 计算从代理请求发出到收到完整响应，真实设备花费的时间
    const elapsedTime = Date.now() - startTime;

    // 将所有最终的响应逻辑包装在一个函数中，以便延迟调用
    const responseAction = () => {
      const realDataString = Buffer.concat(bodyChunks).toString();
      try {
        const realData = JSON.parse(realDataString);
        const modifiedData = matchedRule.modifier!(_.cloneDeep(realData), req);
        const finalStatusCode = matchedRule.statusCode || proxyRes.statusCode || 200;

        res.status(finalStatusCode);
        Object.entries(proxyRes.headers).forEach(([key, value]) => {
          if (value !== undefined) res.setHeader(key, value as string | string[]);
        });
        (res as Response).json(modifiedData); // 使用类型断言以避免 ts(2339)
      } catch (err) {
        console.error("[Modifier] 解析或修改真实设备响应失败", err);
        res.status(matchedRule.statusCode || proxyRes.statusCode || 500).end(realDataString);
      }
    };

    // 3. 核心逻辑：计算还需要“补充”多少延迟
    const desiredDelay = matchedRule.delay || 0;
    // 如果目标延迟大于已耗时，则计算剩余需要等待的时间；否则等待0毫秒（即立即执行）
    const remainingDelay = Math.max(0, desiredDelay - elapsedTime);

    console.log(
      `[CGI Handler] 真实设备耗时: ${elapsedTime}ms, 目标总延迟: ${desiredDelay}ms, 将补充延迟: ${remainingDelay}ms`
    );

    // 4. 应用补充的延迟
    if (remainingDelay > 0) {
      setTimeout(responseAction, remainingDelay);
    } else {
      // 如果真实请求耗时已经超过了目标延迟，则立即响应
      responseAction();
    }
  });
}

// 主逻辑
cgiHandler.post("/cgi", cgiBodyParser, (req: Request, res: Response, next: NextFunction) => {
  if (MOCK_CGI_DATA) {
    return res.status(200).json(MOCK_CGI_DATA);
  }

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

  const matchedRule = findMatchingRule(payload, mockRegistry);

  // --- 分支1: 命中修改器规则 (应用智能延迟) ---
  if (matchedRule?.modifier) {
    console.log("[CGI Handler] 命中“修改器”规则:", matchedRule.requestMatch);

    // 在发起代理前，记录当前时间
    const startTime = Date.now();

    return createProxyMiddleware({
      target: REAL_DEVICE_IP,
      changeOrigin: true,
      selfHandleResponse: true,
      on: {
        proxyReq: (proxyReq) => writeProxyBody(proxyReq, bodyString),
        proxyRes: (proxyRes) => handleModifierResponse(proxyRes, res, matchedRule, req, startTime),
        error: (err, req, res) => {
          console.error("[CGI 代理错误]", err);
          (res as Response).status(502).send("Proxy to CGI device failed");
        },
      },
    })(req, res, next);
  }

  // --- 分支2: 命中静态 Mock 规则 (应用简单延迟) ---
  if (matchedRule?.responseData) {
    console.log("[CGI Handler] 命中静态 Mock 规则:", matchedRule.requestMatch);

    const responseAction = () => {
      const finalStatusCode = matchedRule.statusCode || 200;
      console.log(`[CGI Handler] 返回静态 Mock, 状态码: ${finalStatusCode}, 延迟: ${matchedRule.delay || 0}ms`);
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

  // --- 分支3: 未命中任何规则，交给下一个处理器 (通用代理) ---
  console.log("[CGI Handler] 未命中任何 Mock 规则，放行。");
  return createProxyMiddleware({
    target: REAL_DEVICE_IP,
    changeOrigin: true,
    on: {
      proxyReq: (proxyReq) => writeProxyBody(proxyReq, bodyString),
    },
  })(req, res, next);
});

export { cgiHandler };
