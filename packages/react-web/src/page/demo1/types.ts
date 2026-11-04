// 前端 demo1 使用的 Channel 类型（camelCase），由 ChannelTable / ImportModal / exportUtils 共用

export interface Channel {
    id: string;
    channelName: string;
    linkType: 'Serial' | 'TCP';
    serialPortType?: 'RS232' | 'RS485';
    channelType: 'write' | 'read';
    serverId: string;
    ipAddress?: string;
    port?: number;
    instructionType:
    | 'readCoil'
    | 'readDiscreteInput'
    | 'readHoldingRegister'
    | 'readInputRegister'
    | 'writeSingleCoil'
    | 'writeSingleHoldingRegister'
    | 'writeMultipleCoils'
    | 'writeMultipleHoldingRegister';
    modbusFunctionCode?: number;
    dataType:
    | 'INT16'
    | 'INT32'
    | 'INT64'
    | 'Float32'
    | 'Float64'
    | 'ASCII'
    | 'HEX';
    signed?: boolean;
    byteOrder?: string;
    registerAddress: number;
    registerValue?: string;
    registerCount?: number;
    decimal?: number;
    editable?: boolean;
    isApplied?: boolean;
}
