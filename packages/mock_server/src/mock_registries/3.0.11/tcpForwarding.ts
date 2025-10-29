import { MockRule } from "../../type.js";


export interface TcpForwarding {
    id: string;
    name: string;                          // TCP转发名称
    ip: string;                            // 目标IP地址
    port: number;                          // 目标端口
}

// 系统级参数
export const tcpForwardingLimits = {
    maxForwardings: 1024,                  // 最大转发规则数
    minPort: 1,                            // 最小端口号
    maxPort: 65535,                        // 最大端口号
};

export type TcpForwardingList = TcpForwarding[];


export function generateRandomTcpForwardings(count: number): TcpForwardingList {
    const random = <T>(arr: readonly T[]): T => arr[Math.floor(Math.random() * arr.length)];
    const randomInt = (min: number, max: number): number => Math.floor(Math.random() * (max - min + 1)) + min;
    const randomId = (): string => {
        const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < 10; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    };
    
    // 生成随机IP地址
    const randomIP = (): string => `192.168.${randomInt(1, 255)}.${randomInt(1, 254)}`;

    return Array.from({ length: count }, (_, idx) => {
        const id = randomId();

        return {
            id,
            name: `TCP_${String(idx + 1).padStart(3, '0')}`,
            ip: randomIP(),
            port: randomInt(1, 65535),
        };
    });
}

// 使用示例
export const randomTcpForwardings = generateRandomTcpForwardings(21);


// 生成更多数据用于翻页测试
export const allTcpForwardings = generateRandomTcpForwardings(100); // 生成100个TCP转发规则用于翻页

export const mockData: MockRule[] = [
    {
        requestMatch: {
            id: 47,
            execute: 1,
            core: "yruo_modbus_dataforwarding_tcp",
            function: "get",
            values: [
                { base: "yruo_modbus_dataforwarding_tcp" }
            ],
        },
        // 使用合并后的modifier功能支持翻页
        modifier: (realDeviceResponse, req, payload) => {
            // 新模式：直接生成mock数据（realDeviceResponse为null）
            if (realDeviceResponse === null) {
                // 从请求体中提取翻页参数
                const values = payload.values?.[0];
                const limit = values?.limit || 10;
                const start = values?.start || 0;
                const page = Math.floor(start / limit) + 1;

                console.log(`[TcpForwarding] 动态生成数据: limit=${limit}, start=${start}, page=${page}`);

                // 计算分页数据
                const endIndex = start + limit;
                const paginatedForwardings = allTcpForwardings.slice(start, endIndex);

                console.log(`[TcpForwarding] 返回数据: ${paginatedForwardings.length}条 (start=${start}, limit=${limit})`);

                // 返回正确的响应格式
                return {
                    "get": [
                        {
                            "type": "yruo_modbus_dataforwarding_tcp",
                            "index": 1,
                            "value": {
                                "total": allTcpForwardings.length,
                                "tcp_forwardings": paginatedForwardings
                            }
                        }
                    ]
                };
            }

            // 旧模式：修改真实设备响应（保持向后兼容）
            // 这里可以添加修改真实设备响应的逻辑
            return realDeviceResponse;
        },
    },
]
console.log('[ mockData ] >', mockData)

