import { MockRule } from "./type.d.js"; // 我们将把类型定义也抽离出来

// 这是为 /api 路径准备的 Mock 规则
export const apiMockRegistry: MockRule[] = [
  // 规则1：精确匹配您提供的 curl 命令 (GET 请求)
  {
    // 匹配条件
    requestMatch: {
      method: 'GET',
      path: '/msactility'
      // GET 请求没有 bodyMatch
    },
    // 响应数据
    responseData: {
      success: true,
      message: "msactility status is OK (mocked)",
      data: {
        active_sessions: 5,
        cpu_usage: "22%"
      }
    }
  },

  // 规则2：一个 POST 请求的 Mock 示例，用来演示扩展性
  {
    requestMatch: {
      method: 'POST',
      path: '/users/create',
      // 对于 POST 请求，我们依然可以匹配 body
      bodyMatch: {
        username: "new_user",
        role: "guest"
      }
    },
    responseData: {
      success: true,
      message: "User 'new_user' created successfully (mocked)",
      userId: 12345
    }
  },

  // ... 在这里继续为 /api 路径添加更多规则
];