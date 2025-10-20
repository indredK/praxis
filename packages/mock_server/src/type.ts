import { Request } from "express";

export interface MockRule {
  name?: string; // 规则名称，便于识别
  requestMatch: { [key: string]: any };
  responseData?: object; // 固定的响应数据
  /**
   * 修改器函数，支持两种模式：
   * 1. 修改真实设备返回的数据：modifier(realDeviceResponse, req, payload)
   * 2. 直接生成mock数据：modifier(null, req, payload)
   * 
   * @param realDeviceResponse - 真实设备返回的数据，为null时表示直接生成mock数据
   * @param req - 原始请求对象
   * @param payload - 解析后的请求体
   * @returns - 修改后或生成的数据
   */
  modifier?: (realDeviceResponse: any, req: Request, payload: any) => any;
  delay?: number; // 延迟返回的毫秒数
  statusCode?: number; // 自定义返回的状态码
}
