import { MockRule } from "../../type.js";


export interface Channel {
    id: string;
    // 列表/弹窗字段统一
    channelName: string;                   // 通道名称（展示/编辑/必填）
    linkType: 'Serial' | 'TCP';            // 链路类型（展示/编辑/必选）
    serialPortType?: 'RS232' | 'RS485';    // 串口类型（仅Serial时可选）
    channelType: 'write' | 'read';         // 通道类型（展示/编辑/必选）
    serverId: string;                      // Modbus从站设备地址（必填）
    ipAddress?: string;                    // 仅TCP时必填，仅允许IPv4
    port?: number;                         // 仅TCP时必填，1-65535
    instructionType:
    | 'readCoil'
    | 'readDiscreteInput'
    | 'readHoldingRegister'
    | 'readInputRegister'
    | 'writeSingleCoil'
    | 'writeSingleHoldingRegister'
    | 'writeMultipleCoils'
    | 'writeMultipleHoldingRegister';     // 指令类型（展示/编辑/必选）
    modbusFunctionCode?: number;           // 功能码（展示/自动维护）
    dataType:
    | 'INT16'
    | 'INT32'
    | 'INT64'
    | 'Float32'
    | 'Float64'
    | 'ASCII'
    | 'HEX';                             // 数据类型（展示/编辑/必选）
    signed?: boolean;                      // 有符号/无符号（编辑/规则配置）
    byteOrder?: string;                    // 字节顺序（编辑/规则配置）
    registerAddress: number;               // 寄存器地址（编辑/展示，0~65535）
    registerValue?: string;                // 寄存器值（写指令类型时必填，单个/多个空格分隔）
    registerCount?: number;                // 寄存器数目（读指令类型时必填，1~125）
    decimal?: number;                      // 小数位（读INT类型时可配置，0~9）
    editable?: boolean;                    // 是否可编辑（列表操作使用）
    isApplied?: boolean;                   // 是否应用（列表操作使用）
}

// 系统级参数（校验限制等）
export const channelLimits = {
    maxChannels: 1024,                     // 最大通道数
    maxWriteRegisters: 123,                // 一次最多写入寄存器数
    maxMultiWriteRegisters: 125,           // 写多个寄存器最大数
};

export type ChannelList = Channel[];


export function generateRandomChannels(count: number): ChannelList {
    const linkTypes: Array<'Serial' | 'TCP'> = ['Serial', 'TCP'];
    const serialPortTypes: Array<'RS232' | 'RS485'> = ['RS232', 'RS485'];
    const channelTypes: Array<'write' | 'read'> = ['write', 'read'];
    const instructionTypes = [
        'readCoil',
        'readDiscreteInput',
        'readHoldingRegister',
        'readInputRegister',
        'writeSingleCoil',
        'writeSingleHoldingRegister',
        'writeMultipleCoils',
        'writeMultipleHoldingRegister'
    ] as const;
    const dataTypes = ['INT16', 'INT32', 'INT64', 'Float32', 'Float64', 'ASCII', 'HEX'] as const;
    const byteOrders = ['AB', 'BA', 'AB,CD', 'CD,AB', 'BA,DC', 'DC,BA'];

    const random = <T>(arr: readonly T[]): T => arr[Math.floor(Math.random() * arr.length)];
    const randomInt = (min: number, max: number): number => Math.floor(Math.random() * (max - min + 1)) + min;
    const randomIP = (): string => `192.168.${randomInt(1, 255)}.${randomInt(1, 254)}`;

    return Array.from({ length: count }, (_, idx) => {
        const linkType = random(linkTypes);
        const channelType = random(channelTypes);
        const instructionType = random(instructionTypes);
        const dataType = random(dataTypes);
        const isWriteInstruction = instructionType.includes('write');
        const isCoilInstruction = instructionType.includes('Coil') || instructionType.includes('coil');

        return {
            id: String(idx + 1),
            channelName: `通道_${String(idx + 1).padStart(3, '0')}`,
            linkType,
            serialPortType: linkType === 'Serial' ? random(serialPortTypes) : undefined,
            channelType,
            serverId: String(randomInt(1, 247)),
            ipAddress: linkType === 'TCP' ? randomIP() : undefined,
            port: linkType === 'TCP' ? randomInt(1024, 65535) : undefined,
            instructionType,
            modbusFunctionCode: randomInt(1, 16),
            dataType,
            signed: !isCoilInstruction ? Math.random() > 0.5 : undefined,
            byteOrder: !isCoilInstruction ? random(byteOrders) : undefined,
            registerAddress: randomInt(0, 65535),
            registerValue: isWriteInstruction ?
                (instructionType.includes('Multiple') ?
                    Array.from({ length: randomInt(1, 5) }, () => randomInt(0, 65535)).join(' ') :
                    String(randomInt(0, 65535))
                ) : undefined,
            registerCount: !isWriteInstruction ? randomInt(1, 125) : undefined,
            decimal: dataType.includes('INT') ? randomInt(0, 9) : undefined,
            editable: Math.random() > 0.1, // 90%可编辑
            isApplied: Math.random() > 0.5, // 50%应用
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
            core: "yruo_firewall_iorules",
            function: "get",
            values: [
                { base: "yruo_firewall_channelSettings" }
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
                            "type": "yruo_firewall_channelSettings",
                            "index": 1,
                            "value": {
                                "server_count": allChannels.length,
                                "server": paginatedChannels
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