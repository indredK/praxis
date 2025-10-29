import { MockRule } from "../../type.js";


export interface Channel {
    id: string;
    channel_name: string;                  // 通道名称（展示/编辑/必填）
    link_type: number;                     // 链路类型（展示/编辑/必选）：0=Serial, 1=TCP
    server_id: string;                     // Modbus从站设备地址（必填）
    ip_address: string;                    // IP地址
    port: number;                          // 端口，1-65535
    command_type:
    | 'read_coils'
    | 'read_discrete_inputs'
    | 'read_holding_registers'
    | 'read_input_registers'
    | 'write_single_coil'
    | 'write_single_register'
    | 'write_multiple_coils'
    | 'write_multiple_registers';          // 指令类型（展示/编辑/必选）
    data_type:
    | 'INT16'
    | 'INT32'
    | 'INT64'
    | 'Float32'
    | 'Float64'
    | 'ASCII'
    | 'HEX';                               // 数据类型（展示/编辑/必选）
    signed: boolean;                       // 有符号/无符号（编辑/规则配置）
    byte_order: string;                    // 字节顺序（编辑/规则配置）
    register_address: number;              // 寄存器地址（编辑/展示，0~65535）
    register_value: string;                // 寄存器值
    register_count: number;                // 寄存器数目（1~125）
    decimal_places: number;                // 小数位（0~9）
    isApplied: boolean;                    // 是否应用（列表操作使用）
}

// 系统级参数（校验限制等）
export const channelLimits = {
    maxChannels: 1024,                     // 最大通道数
    maxWriteRegisters: 123,                // 一次最多写入寄存器数
    maxMultiWriteRegisters: 125,           // 写多个寄存器最大数
};

export type ChannelList = Channel[];


export function generateRandomChannels(count: number): ChannelList {
    const linkTypes = [0, 1]; // 0=Serial, 1=TCP
    const commandTypes = [
        'read_coils',
        'read_discrete_inputs',
        'read_holding_registers',
        'read_input_registers',
        'write_single_coil',
        'write_single_register',
        'write_multiple_coils',
        'write_multiple_registers'
    ] as const;
    const dataTypes = ['INT16', 'INT32', 'INT64', 'Float32', 'Float64', 'ASCII', 'HEX'] as const;
    
    // 字节顺序选项（根据数据类型）
    const byteOrderOptions = {
        INT16: ['AB', 'BA'],
        INT32: ['AB,CD', 'CD,AB', 'BA,DC', 'DC,BA'],
        INT64: ['AB,CD,EF,GH', 'GH,EF,CD,AB', 'BA,DC,FE,HG', 'HG,FE,DC,BA'],
        Float32: ['AB,CD', 'CD,AB', 'BA,DC', 'DC,BA'],
        Float64: ['AB,CD,EF,GH', 'GH,EF,CD,AB', 'BA,DC,FE,HG', 'HG,FE,DC,BA'],
        ASCII: ['ASCII'],
        HEX: ['HEX'],
    };

    const random = <T>(arr: readonly T[]): T => arr[Math.floor(Math.random() * arr.length)];
    const randomInt = (min: number, max: number): number => Math.floor(Math.random() * (max - min + 1)) + min;
    const randomIP = (): string => `192.168.${randomInt(1, 255)}.${randomInt(1, 254)}`;
    
    // 根据数据类型获取对应的字节顺序
    const getByteOrder = (dataType: typeof dataTypes[number]): string => {
        return random(byteOrderOptions[dataType]);
    };

    return Array.from({ length: count }, (_, idx) => {
        const link_type = random(linkTypes);
        const command_type = random(commandTypes);
        const data_type = random(dataTypes);
        const isWriteCommand = command_type.includes('write');

        return {
            id: String(idx + 1),
            channel_name: `Channel_${String(idx + 1).padStart(3, '0')}`,
            link_type,
            server_id: `Server_${String(randomInt(1, 247)).padStart(2, '0')}`,
            ip_address: randomIP(),
            port: randomInt(1, 65535),
            command_type,
            data_type,
            signed: Math.random() > 0.5,
            byte_order: getByteOrder(data_type),
            register_address: randomInt(0, 65535),
            register_value: isWriteCommand ?
                (command_type.includes('multiple') ?
                    Array.from({ length: randomInt(1, 5) }, () => randomInt(0, 65535)).join(' ') :
                    String(randomInt(0, 65535))
                ) : String(randomInt(0, 65535)),
            register_count: randomInt(1, 125),
            decimal_places: randomInt(0, 9),
            isApplied: Math.random() > 0.5,
        };
    });
}

// 使用示例
export const randomChannels = generateRandomChannels(21);


// 生成更多数据用于翻页测试
export const allChannels = generateRandomChannels(100); // 生成100个通道用于翻页

export const mockData: MockRule[] = [
    {
        requestMatch: {
            id: 47,
            execute: 1,
            core: "yruo_modbus_channelsettings",
            function: "get",
            values: [
                { base: "yruo_modbus_channelsettings" }
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

                console.log(`[ChannelSettings] 动态生成数据: limit=${limit}, start=${start}, page=${page}`);

                // 计算分页数据
                const endIndex = start + limit;
                const paginatedChannels = allChannels.slice(start, endIndex);

                console.log(`[ChannelSettings] 返回数据: ${paginatedChannels.length}条 (start=${start}, limit=${limit})`);

                // 返回正确的响应格式
                return {
                    "get": [
                        {
                            "type": "yruo_modbus_channelsettings",
                            "index": 1,
                            "value": {
                                "total": allChannels.length,
                                "channelsettings": paginatedChannels
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