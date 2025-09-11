import { Request } from 'express';

export interface MockRule {
  requestMatch: { [key: string]: any };
  responseData?: object; // 固定的响应数据
    /**
   * 修改真实设备返回的数据 优先级最高
   * @param proxyResData - 真实设备返回的数据
   * @param req - 原始请求对象
   * @returns - 修改后的数据
   */
  modifier?: (proxyResData: any, req: Request) => any;
}