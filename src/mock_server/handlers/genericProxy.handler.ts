import { createProxyMiddleware } from 'http-proxy-middleware';
import { REAL_DEVICE_IP } from '../config';
import { Response } from 'express'; // 导入 Response 类型

const genericProxyHandler = createProxyMiddleware({
  target: REAL_DEVICE_IP,
  changeOrigin: true,
  on: {
    proxyRes: (proxyRes, req, res) => {
      console.log(`[通用代理] 路径: ${req.url}, 收到响应码:`, proxyRes.statusCode);
    },
    error: (err, req, res) => {
      console.error(`[通用代理错误] 路径: ${req.url}`, err);
      // 添加类型断言，确保 res 对象上的方法可用
      if (!(res as Response).headersSent) {
        (res as Response).status(502).send('Proxy Error');
      }
    }
  }
});

export { genericProxyHandler };