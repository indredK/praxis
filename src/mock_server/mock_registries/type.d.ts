export type mockRegistryType = Array<{
  requestMatch: { [key: string]: any };
  responseData: { [key: string]: any };
}>;


export interface MockRule {
  requestMatch: {
    method?: 'GET' | 'POST' | 'PUT' | 'DELETE'; // 请求方法 (可选)
    path?: string; // 精确路径 (可选)
    pathStartsWith?: string; // 路径前缀 (可选)
    bodyMatch?: object; // 要匹配的请求体 (可选)
  };
  responseData: object; // 固定的响应数据
}