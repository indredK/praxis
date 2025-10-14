export interface ChannelData {
  id: string;
  channelName: string;
  linkType: string;
  serverId: string;
  ipAddress?: string;
  port?: string;
  instructionType: string;
  dataType?: string;
  byteOrder?: string;
  registerAddress: string;
  registerValue?: string;
  registerCount?: string;
  isSigned?: boolean;
  decimalPlaces?: number;
  isApplied?: boolean; // 通道应用状态：true-正在应用中，false-未在应用中
}

export const mockChannelData: ChannelData[] = [
  {
    id: '1',
    channelName: '通道1',
    linkType: 'serial',
    serverId: '1',
    instructionType: 'writeMultipleHoldingRegisters',
    dataType: 'INT16',
    byteOrder: 'AB',
    registerAddress: '40000',
    registerValue: '20 26',
    isApplied: false, // 未在应用中
  },
  {
    id: '2',
    channelName: '通道2',
    linkType: 'serial',
    serverId: '1',
    instructionType: 'writeMultipleHoldingRegisters',
    dataType: 'INT16',
    byteOrder: 'AB',
    registerAddress: '40001',
    registerValue: '20 27',
    isApplied: true, // 正在应用中
  },
  {
    id: '3',
    channelName: '通道3',
    linkType: 'serial',
    serverId: '1',
    instructionType: 'writeSingleHoldingRegister',
    dataType: 'INT16',
    byteOrder: 'AB',
    registerAddress: '40002',
    registerValue: '20 27',
    isApplied: false, // 未在应用中
  },
  {
    id: '4',
    channelName: '通道4',
    linkType: 'serial',
    serverId: '1',
    instructionType: 'writeSingleHoldingRegister',
    dataType: 'INT16',
    byteOrder: 'AB',
    registerAddress: '40003',
    registerValue: '20 27',
    isApplied: true, // 正在应用中
  },
  {
    id: '5',
    channelName: '通道5',
    linkType: 'serial',
    serverId: '1',
    instructionType: 'writeSingleHoldingRegister',
    dataType: 'INT16',
    byteOrder: 'AB',
    registerAddress: '40004',
    registerValue: '20 27',
    isApplied: false, // 未在应用中
  },
  {
    id: '6',
    channelName: '通道6',
    linkType: 'serial',
    serverId: '1',
    instructionType: 'writeSingleHoldingRegister',
    dataType: 'INT16',
    byteOrder: 'AB',
    registerAddress: '40005',
    registerValue: '20 27',
    isApplied: false, // 未在应用中
  },
  {
    id: '7',
    channelName: '通道7',
    linkType: 'serial',
    serverId: '1',
    instructionType: 'readHoldingRegisters',
    dataType: 'INT16',
    byteOrder: 'AB',
    registerAddress: '40006',
    registerCount: '1',
    decimalPlaces: 0,
    isApplied: true, // 正在应用中
  },
  {
    id: '8',
    channelName: '通道8',
    linkType: 'serial',
    serverId: '1',
    instructionType: 'readHoldingRegisters',
    dataType: 'INT16',
    byteOrder: 'AB',
    registerAddress: '40007',
    registerCount: '2',
    decimalPlaces: 0,
    isApplied: false, // 未在应用中
  },
  {
    id: '9',
    channelName: '通道9',
    linkType: 'serial',
    serverId: '1',
    instructionType: 'readHoldingRegisters',
    dataType: 'INT16',
    byteOrder: 'AB',
    registerAddress: '40008',
    registerCount: '3',
    decimalPlaces: 0,
    isApplied: false, // 未在应用中
  },
  {
    id: '10',
    channelName: '通道10',
    linkType: 'serial',
    serverId: '1',
    instructionType: 'readHoldingRegisters',
    dataType: 'INT16',
    byteOrder: 'AB',
    registerAddress: '40009',
    registerCount: '4',
    decimalPlaces: 0,
    isApplied: true, // 正在应用中
  },
];

