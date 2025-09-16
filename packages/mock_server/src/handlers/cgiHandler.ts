import express, { Router, Request, Response, NextFunction } from "express";
import { createProxyMiddleware } from "http-proxy-middleware";
import _ from "lodash";
import { findMatchingRule } from "./utils.js";
import { MockRule } from "../type.js";

// 定义依赖接口
interface CgiHandlerDependencies {
  registry: MockRule[];
  proxyTarget: string;
}

// 2. 整个文件被一个工厂函数包裹，它接收 registry 作为参数
export function createCgiHandler({ registry, proxyTarget }: CgiHandlerDependencies): Router {
  const cgiHandler = Router();
  const cgiBodyParser = express.text({ type: "application/x-www-form-urlencoded" });

  // --- 您的所有内部工具函数和业务逻辑保持原样 ---

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
    startTime: number
  ) {
    const bodyChunks: Buffer[] = [];
    proxyRes.on("data", (chunk: Buffer) => bodyChunks.push(chunk));
    proxyRes.on("end", () => {
      const elapsedTime = Date.now() - startTime;
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
          (res as Response).json(modifiedData);
        } catch (err) {
          console.error("[Modifier] 解析或修改真实设备响应失败", err);
          res.status(matchedRule.statusCode || proxyRes.statusCode || 500).end(realDataString);
        }
      };
      const desiredDelay = matchedRule.delay || 0;
      const remainingDelay = Math.max(0, desiredDelay - elapsedTime);

      console.log(
        `[CGI Handler] 真实设备耗时: ${elapsedTime}ms, 目标总延迟: ${desiredDelay}ms, 将补充延迟: ${remainingDelay}ms`
      );

      if (remainingDelay > 0) {
        setTimeout(responseAction, remainingDelay);
      } else {
        responseAction();
      }
    });
  }

  // --- 您的主逻辑保持原样 ---
  cgiHandler.post("/cgi", cgiBodyParser, (req: Request, res: Response, next: NextFunction) => {
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

    // 3. 使用传入的 registry 参数，而不是写死的 import
    const matchedRule = findMatchingRule(payload, registry);

    // --- 分支1: 命中静态 Mock 规则 (应用简单延迟) ---
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

    // --- 分支2: 命中修改器规则 (应用智能延迟) ---
    if (matchedRule?.modifier) {
      console.log("[CGI Handler] 命中“修改器”规则:", matchedRule.requestMatch);
      const startTime = Date.now();
      return createProxyMiddleware({
        target: proxyTarget,
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

    // --- 分支3: 未命中任何规则，交给下一个处理器 (通用代理) ---
    console.log("[CGI Handler] 未命中任何 Mock 规则，放行。");
    return createProxyMiddleware({
      target: proxyTarget,
      changeOrigin: true,
      on: {
        proxyReq: (proxyReq) => writeProxyBody(proxyReq, bodyString),
      },
    })(req, res, next);
  });

  // 4. 函数最后返回配置好的 cgiHandler 实例
  return cgiHandler;
}

// 5. 不再直接导出 cgiHandler 实例
// export { cgiHandler };
