import _ from 'lodash';
import { mockRegistryType, MockRule } from "../mock_registries/type.d.js";
import { Request, Response } from "express";

/**
 * 检查请求是否命中 Mock 规则，如果命中则处理并返回 true。
 * @param req 原始请求对象
 * @param res 原始响应对象
 * @returns {boolean} 如果命中了 Mock 规则并已处理，返回 true；否则返回 false。
 */
export function dispatchMock(req: Request, res: Response, mockRegistry: mockRegistryType): boolean {

  const bodyString = req.body;
  const payload = JSON.parse(bodyString);

  // 遍历我们定义的所有规则
  for (const rule of mockRegistry) {
    if (_.isMatch(payload, rule.requestMatch)) {
      console.log("[Mock Handler] 命中 Lodash 匹配规则, 匹配条件:", rule.requestMatch);
      // 如果匹配成功，发送对应的响应数据
      res.json(rule.responseData);
      // 并返回 true，表示请求已处理
      return true;
    }
  }

  // 如果遍历完所有规则都没找到匹配的，返回 false
  return false;
}



export function apiDispatchMock(req: Request, res: Response, registry: MockRule[]): boolean {
  for (const rule of registry) {
    const { method, path, pathStartsWith, bodyMatch } = rule.requestMatch;

    // 检查方法是否匹配
    if (method && req.method.toUpperCase() !== method.toUpperCase()) {
      continue; // 不匹配，跳过此规则
    }
    // 检查精确路径是否匹配
    if (path && req.path !== path) {
      continue;
    }
    // 检查路径前缀是否匹配
    if (pathStartsWith && !req.path.startsWith(pathStartsWith)) {
      continue;
    }
    // 如果需要，检查 body 是否匹配 (使用 lodash)
    if (bodyMatch && !_.isMatch(req.body, bodyMatch)) {
      continue;
    }

    // 所有条件都满足，我们找到了匹配的规则！
    console.log('[Mock Handler] 命中一条 Mock 规则, 匹配条件:', rule.requestMatch);
    res.json(rule.responseData);
    return true; // 已处理
  }

  return false; // 未命中
}