import { MockRule } from "../../src/type";

export const testApiRegistry: MockRule[] = [
  {
    // name: 'API 静态 Mock 测试规则',
    requestMatch: { method: "GET", path: "/user/profile" },
    responseData: {
      success: true,
      user: { id: "test-user", name: "Test User" },
    },
  },
];
