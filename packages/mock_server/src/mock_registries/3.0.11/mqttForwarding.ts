import { MockRule } from "../../type.js";


export interface MqttForwarding {
    id: string;
    mqtt_name: string;                     // MQTT名称
    modbus_name: string;                   // Modbus通道名称
    topic: string;                         // MQTT主题
    qos: number;                           // QoS等级 (0, 1, 2)
    flag: number;                          // 标志位
}

// 系统级参数
export const mqttForwardingLimits = {
    maxForwardings: 1024,                  // 最大转发规则数
    maxQos: 2,                             // 最大QoS等级
};

export type MqttForwardingList = MqttForwarding[];


export function generateRandomMqttForwardings(count: number): MqttForwardingList {
    const qosLevels = [0, 1, 2]; // QoS等级
    const flagValues = [0, 1]; // 标志位
    const modbusChannels = [
        'All Channel',
        'Channel_001',
        'Channel_002',
        'Channel_003',
        'Channel_004',
        'Channel_005'
    ];
    
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
    
    // 生成随机主题
    const randomTopic = (idx: number): string => {
        const topics = [
            `modbus/channel/${idx}`,
            `data/sensor/${idx}`,
            `device/status/${idx}`,
            `iot/data/${idx}`,
            `mqtt/topic/${randomInt(100, 999)}`
        ];
        return random(topics);
    };

    return Array.from({ length: count }, (_, idx) => {
        const id = randomId();

        return {
            id,
            mqtt_name: `MQTT_${String(idx + 1).padStart(3, '0')}`,
            modbus_name: random(modbusChannels),
            topic: randomTopic(idx + 1),
            qos: random(qosLevels),
            flag: random(flagValues),
        };
    });
}

// 使用示例
export const randomMqttForwardings = generateRandomMqttForwardings(21);


// 生成更多数据用于翻页测试
export const allMqttForwardings = generateRandomMqttForwardings(100); // 生成100个MQTT转发规则用于翻页

export const mockData: MockRule[] = [
    {
        requestMatch: {
            id: 47,
            execute: 1,
            core: "yruo_modbus_dataforwarding_mqtt",
            function: "get",
            values: [
                { base: "yruo_modbus_dataforwarding_mqtt" }
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

                console.log(`[MqttForwarding] 动态生成数据: limit=${limit}, start=${start}, page=${page}`);

                // 计算分页数据
                const endIndex = start + limit;
                const paginatedForwardings = allMqttForwardings.slice(start, endIndex);

                console.log(`[MqttForwarding] 返回数据: ${paginatedForwardings.length}条 (start=${start}, limit=${limit})`);

                // 返回正确的响应格式
                return {
                    "get": [
                        {
                            "type": "yruo_modbus_dataforwarding_mqtt",
                            "index": 1,
                            "value": {
                                "total": allMqttForwardings.length,
                                "mqtt_forwardings": paginatedForwardings
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

