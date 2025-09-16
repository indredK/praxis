import { Request } from "express";

export interface MockRule {
  name?: string; // 规则名称，便于识别
  requestMatch: { [key: string]: any };
  responseData?: object; // 固定的响应数据
  /**
   * 修改真实设备返回的数据 优先级最高
   * @param proxyResData - 真实设备返回的数据
   * @param req - 原始请求对象
   * @returns - 修改后的数据
   */
  modifier?: (proxyResData: any, req: Request) => any;
  delay?: number; // 延迟返回的毫秒数
  statusCode?: number; // 自定义返回的状态码
}
