import { cgiHandler } from './cgi.handler';
import { apiHandler } from './api.handler';
import { genericProxyHandler } from './genericProxy.handler';

// 这就是我们的责任链！请求会按顺序流经它们。
export const requestHandlers = [
  cgiHandler,
  apiHandler,
  genericProxyHandler // 通用代理永远是最后一环
];