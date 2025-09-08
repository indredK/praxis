import { Router, Request, Response, NextFunction } from 'express';
import { REAL_DEVICE_IP } from '../config.js';
import http from 'http'; // 关键：导入 Node.js 原生 http 模块
import { URL } from 'url'; // 关键：导入 URL 模块用于解析地址
import { apiDispatchMock } from './utils.js';
import { apiMockRegistry } from '../mock_registries/api.mockRegistry.js';
import chalk from 'chalk';



const apiHandler = Router();

// 这个处理器将处理所有 /api 请求
apiHandler.use('/api', (req: Request, res: Response) => {
  if (apiDispatchMock(req, res, apiMockRegistry)) {
    return;
  }

  console.log(chalk.yellow(`[原生代理] 接收到请求: ${req.method} ${req.originalUrl}`));

  // 1. 解析目标服务器的地址信息
  const targetUrl = new URL(REAL_DEVICE_IP);

  // 2. 准备转发请求的选项
  const options: http.RequestOptions = {
    hostname: targetUrl.hostname,
    port: targetUrl.port || 80,
    path: req.originalUrl, // 使用 originalUrl 以保留完整的路径和查询参数
    method: req.method,
    headers: {
      ...req.headers,
      host: targetUrl.host, // 必须重写 host 头部！
    },
  };

  // 3. 创建一个代理请求
  const proxyReq = http.request(options, (proxyRes) => {
    // 4. 收到真实设备的响应
    console.log(chalk.yellow(`[原生代理] 收到设备响应码: ${proxyRes.statusCode}`));

    // 将真实设备的响应头写回给浏览器
    res.writeHead(proxyRes.statusCode!, proxyRes.headers);

    // 5. 将真实设备的响应体，通过管道流式传输回浏览器
    proxyRes.pipe(res, { end: true });
  });

  // 6. 监听代理请求的错误事件
  proxyReq.on('error', (err) => {
    console.error('[原生代理] 请求转发错误:', err);
    if (!res.headersSent) {
      res.status(502).send('Bad Gateway');
    }
    res.end();
  });

  // 7. 将浏览器的请求体，通过管道流式传输给真实设备
  // 这能完美处理 GET (无body) 和 POST (有body) 等所有情况
  req.pipe(proxyReq, { end: true });
});

export { apiHandler };