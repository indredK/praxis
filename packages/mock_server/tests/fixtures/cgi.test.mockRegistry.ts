import { produce } from "immer";
import { MockRule } from "../../src/type.js";

export const testCgiRegistry: MockRule[] = [
  // 规则1: 用于测试 Modifier 功能
  {
    requestMatch: { core: "yruo_status", function: "get", values: [{ base: "summary" }] },
    modifier: (realDeviceResponse) => {
      // 使用 produce 来安全地修改数据
      return produce<any>(realDeviceResponse, (draft) => {
        // 在修改前，先确保路径存在，这更健壮
        if (draft.data?.summary) {
          draft.data.summary.uptime = "MODIFIED_BY_TEST";
        }
      });
    },
  },
  // 规则2: 用于测试静态 Mock 功能
  {
    // name: '获取设备详情 - 静态 Mock 测试',
    requestMatch: { core: "yruo_status", function: "get", values: [{ base: "details" }] },
    responseData: {
      success: true,
      data: { details: { firmware: "v2.1.0-mock" } },
    },
  },
];
