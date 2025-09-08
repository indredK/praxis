import express, { Request, Response, NextFunction, Router } from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { MOCK_CGI_DATA, REAL_DEVICE_IP } from '../config.js';
import { mockRegistry } from '../mock_registries/cgi.mockRegistry.js';
import { dispatchMock } from './utils.js'; // 我们将 dispatchMock 也抽离

const cgiHandler = Router();
const cgiBodyParser = express.text({ type: 'application/x-www-form-urlencoded' });

cgiHandler.post('/cgi', cgiBodyParser, (req: Request, res: Response, next: NextFunction) => {
  // --- 检查全局 Mock 开关 ---
  if (MOCK_CGI_DATA) {
    return res.status(200).json(MOCK_CGI_DATA);
  }

  const bodyString = req.body;
  if (typeof bodyString !== 'string' || bodyString.length === 0) {
    return next(); // 如果没 body，交给下一个处理器
  }
  // 尝试命中 Mock 规则
  if (dispatchMock(req, res, mockRegistry)) {
    return; // Mock 成功，结束
  }

  // Mock 未命中，创建专属代理转发
  const cgiProxy = createProxyMiddleware({
    target: REAL_DEVICE_IP,
    changeOrigin: true,
    on: {
      proxyReq: (proxyReq, req, res) => {
        proxyReq.setHeader("Content-Length", Buffer.byteLength(bodyString));
        proxyReq.write(bodyString);
      },
    },
  });

  return cgiProxy(req, res, next);
});

export { cgiHandler };