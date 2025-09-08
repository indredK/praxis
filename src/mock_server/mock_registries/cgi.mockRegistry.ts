import { mockRegistryType } from "./type";

export const mockRegistry: mockRegistryType = [
  // 规则1：完全匹配您 curl 命令中的请求
  {
    // 当请求体中同时包含这些字段且值相等时，此规则被触发
    requestMatch: {
      core: 'yruo_status',
      function: 'get',
      values: [
        { base: 'summary' }
      ]
    },
    // 触发后，返回下面的数据
    responseData: {
      success: true,
      data: {
        summary: {
          uptime: "1 day, 2 hours, 15 minutes (mocked)",
          cpu_load: "5%",
          memory_usage: "128MB / 512MB"
        }
      }
    }
  },

  // 规则2：一个更简单的例子，只匹配部分关键字段
  {
    requestMatch: {
      core: 'network_config',
      function: 'set'
      // 注意：这里我们不关心 'values' 字段是什么，只要 core 和 function 匹配即可
    },
    responseData: {
      success: true,
      message: 'Network configuration updated successfully (mocked).'
    }
  },

  // 规则3：另一个获取状态的例子
  {
    requestMatch: {
      core: 'yruo_status',
      function: 'get',
      values: [
        { base: 'details' } // 与规则1的 values 不同
      ]
    },
    responseData: {
      success: true,
      data: {
        details: {
          firmware: "v2.1.0-mock",
          serial_number: "SN-MOCK-12345"
        }
      }
    }
  },

  // ... 在这里继续添加您的 Mock 规则 ...
];