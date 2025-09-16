// /packages/mock-server/src/handlers/index.ts

import { Router, RequestHandler } from "express"; // <-- 1. 额外导入 RequestHandler 类型
import { createCgiHandler } from "./cgiHandler.js";
import { createApiHandler } from "./apiHandler.js";
import { createGenericProxyHandler } from "./genericProxyHandler.js";
import { MockRule } from "../type.js";

interface HandlerDependencies {
  cgiRegistry: MockRule[];
  apiRegistry: MockRule[];
  proxyTarget: string;
}

// 2. 将返回类型从 Router[] 修改为 RequestHandler[]
export function createRequestHandlers(dependencies: HandlerDependencies): RequestHandler[] {
  const { cgiRegistry, apiRegistry, proxyTarget } = dependencies;

  // 将依赖分别注入到各个子工厂中
  const cgiHandler = createCgiHandler({ registry: cgiRegistry, proxyTarget });
  const apiHandler = createApiHandler({ registry: apiRegistry, proxyTarget });
  const genericProxyHandler = createGenericProxyHandler({ target: proxyTarget });

  return [cgiHandler, apiHandler, genericProxyHandler];
}
