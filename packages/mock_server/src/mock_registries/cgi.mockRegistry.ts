import { produce } from "immer";
import { MockRule } from "../type.js";
import { mockData } from "./3.0.11";

export const cgiMockRegistry: MockRule[] = [
  // 规则1：完全匹配您 curl 命令中的请求
  {
    // 当请求体中同时包含这些字段且值相等时，此规则被触发
    requestMatch: {
      core: "yruo_status",
      function: "get",
      values: [{ base: "summary" }],
    },
    statusCode: 200,
    delay: 500, // 延迟 500ms 再响应
    modifier: (realDeviceResponse, originalRequest) => {
      console.log("[Modifier] 接收到的真实设备响应:", realDeviceResponse);
      // 返回修改后的版本
      return realDeviceResponse;
    },
    // 触发后，返回下面的数据
    // responseData: {
    //   success: true,
    //   data: {
    //     summary: {
    //       uptime: "1 day, 2 hours, 15 minutes (mocked)",
    //       cpu_load: "5%",
    //       memory_usage: "128MB / 512MB"
    //     }
    //   }
    // }
  },

  // 规则2：一个更简单的例子，只匹配部分关键字段
  {
    requestMatch: {
      core: "yruo_usermanagement",
      function: "get",
      values: [{ base: "check_pass" }],
      // 注意：这里我们不关心 'values' 字段是什么，只要 core 和 function 匹配即可
    },
    modifier: (realDeviceResponse, originalRequest) => {
      // 2. 调用 produce 函数
      const modifiedResponse = produce<any>(realDeviceResponse, (draft) => {
        // "draft" 是 realDeviceResponse 的一个安全代理
        // 在这个函数内部，你可以“肆无忌惮”地、用最直接的方式去修改 draft
        // Immer 会保证原数据 realDeviceResponse 绝对安全

        // 3. 使用可选链(?.)来安全地访问深层属性，避免因路径不存在而崩溃
        if (draft.result?.[0]?.get?.[0]?.value) {
          draft.result[0].get[0].value.default = 0; // 像普通对象一样直接赋值
        }

        // 你还可以做更多修改
        draft.modifiedBy = "Immer";
      });

      // 4. produce 函数会自动返回一个全新的、更新后的对象
      return modifiedResponse;
    },
  },

  // 规则3：另一个获取状态的例子
  {
    requestMatch: {
      core: "yruo_status",
      function: "get",
      values: [
        { base: "details" }, // 与规则1的 values 不同
      ],
    },
    responseData: {
      success: true,
      data: {
        details: {
          firmware: "v2.1.0-mock",
          serial_number: "SN-MOCK-12345",
        },
      },
    },
  },
  // yruo_firewall_iorules 以色列 - 更精确的匹配
  {
    requestMatch: {
      core: "yruo_firewall_iorules",
      function: "get",
      values: [
        { base: "yruo_firewall_iorules" }, // 只匹配这个特定的base
      ],
    },
    responseData: {
      "id": 5,
      "model": "UR35",
      "pn": "L04EU2211111CN0010000000",
      "oem": "0000",
      "rtver": "35.3.0.10-r1",
      "status": 0,
      "result": [
        {
          "get": [
            {
              "type": "yruo_firewall_policy",
              "index": 1,
              "value": {
                "inbound_policy": 1,
                "outbound_policy": 2,
                "list": [
                  "ALL",
                  "WAN"
                ]
              }
            },
            {
              "type": "yruo_firewall_inbound_list",
              "index": 1,
              "value": {
                "priority": 1,
                "interface": "ALL",
                "source_ip": "192.168.50.50",
                "source_port": 29,
                "action": 2,
                "protocol": "UDP",
                "device_port": 99,

              }
            },
            {
              "type": "yruo_firewall_outbound_list",
              "index": 1,
              "value": {
                "priority": 1,
                "interface": "ALL",
                "target_ip": "192.168.50.50",
                "target_port": 22,
                "action": 2,
                "protocol": "UDP",
              }
            },
            {
              "type": "yruo_firewall_outbound_list",
              "index": 2,
              "value": {
                "priority": 2,
                "interface": "ALL",
                "target_ip": "192.168.50.51",
                "target_port": 33,
                "action": 2,
                "protocol": "UDP",
              }
            }
          ]
        }
      ]
    },
  },
  ...mockData
];
