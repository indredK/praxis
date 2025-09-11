import _ from 'lodash';
import { MockRule } from "../mock_registries/type.d.js";
import { Request } from "express";

/**
 * 遍历注册表，查找与请求体匹配的第一个规则。
 * @param payload - 解析后的请求体
 * @param registry - Mock 规则注册表
 * @returns {MockRule | undefined} - 返回匹配到的规则对象，如果没找到则返回 undefined
 */
export function findMatchingRule(payload: any, registry: MockRule[]): MockRule | undefined {
  for (const rule of registry) {
    if (_.isMatch(payload, rule.requestMatch)) {
      return rule; // 找到即返回
    }
  }
  return undefined; // 遍历完未找到
}


/**
 * 遍历 API 注册表，查找与当前请求匹配的第一个规则。
 * @param req - Express 的请求对象
 * @param registry - Mock 规则注册表
 * @returns {MockRule | undefined} - 返回匹配到的规则对象，如果没找到则返回 undefined
 */
export function findApiRule(req: Request, registry: MockRule[]): MockRule | undefined {
  for (const rule of registry) {
    const { method, path, pathStartsWith, bodyMatch } = rule.requestMatch;

    if (method && req.method.toUpperCase() !== method.toUpperCase()) continue;
    if (path && req.path !== path) continue;
    if (pathStartsWith && !req.path.startsWith(pathStartsWith)) continue;
    if (bodyMatch && !_.isMatch(req.body, bodyMatch)) continue;

    // 所有条件都满足
    return rule;
  }
  return undefined;
}


