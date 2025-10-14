// 链路类型选项
export const linkTypeOptions = [
    { label: '串口1($RSXXX)', value: 'serial1' },
    { label: '串口2($RSXXX)', value: 'serial2' },
    { label: '串口($RSXXX)', value: 'serial' },
    { label: 'TCP', value: 'tcp' },
];

// 指令类型选项
export const instructionTypeOptions = [
    { label: '读线圈', value: 'readCoils' },
    { label: '读离散输入', value: 'readDiscreteInputs' },
    { label: '读保持寄存器', value: 'readHoldingRegisters' },
    { label: '读输入寄存器', value: 'readInputRegisters' },
    { label: '写单个线圈', value: 'writeSingleCoil' },
    { label: '写单个保持寄存器', value: 'writeSingleHoldingRegister' },
    { label: '写多个线圈', value: 'writeMultipleCoils' },
    { label: '写多个保持寄存器', value: 'writeMultipleHoldingRegisters' },
];

// 数据类型选项
export const dataTypeOptions = [
    { label: 'INT16', value: 'INT16' },
    { label: 'INT32', value: 'INT32' },
    { label: 'INT64', value: 'INT64', isNew: true },
    { label: 'Float32', value: 'Float32' },
    { label: 'Float64', value: 'Float64', isNew: true },
    { label: 'ASCII', value: 'ASCII', isNew: true },
    { label: 'HEX', value: 'HEX', isNew: true },
];

// 字节顺序选项
export const byteOrderOptions = {
    INT16: [
        { label: 'AB', value: 'AB' },
        { label: 'BA', value: 'BA' },
    ],
    INT32: [
        { label: 'AB,CD', value: 'AB,CD' },
        { label: 'CD,AB', value: 'CD,AB' },
        { label: 'BA,DC', value: 'BA,DC' },
        { label: 'DC,BA', value: 'DC,BA' },
    ],
    Float32: [
        { label: 'AB,CD', value: 'AB,CD' },
        { label: 'CD,AB', value: 'CD,AB' },
        { label: 'BA,DC', value: 'BA,DC' },
        { label: 'DC,BA', value: 'DC,BA' },
    ],
    INT64: [
        { label: 'AB,CD,EF,GH', value: 'AB,CD,EF,GH' },
        { label: 'GH,EF,CD,AB', value: 'GH,EF,CD,AB' },
        { label: 'BA,DC,FE,HG', value: 'BA,DC,FE,HG' },
        { label: 'HG,FE,DC,BA', value: 'HG,FE,DC,BA' },
    ],
    Float64: [
        { label: 'AB,CD,EF,GH', value: 'AB,CD,EF,GH' },
        { label: 'GH,EF,CD,AB', value: 'GH,EF,CD,AB' },
        { label: 'BA,DC,FE,HG', value: 'BA,DC,FE,HG' },
        { label: 'HG,FE,DC,BA', value: 'HG,FE,DC,BA' },
    ],
    ASCII: [
        { label: 'ASCII', value: 'ASCII' },
    ],
    HEX: [
        { label: 'HEX', value: 'HEX' },
    ],
};

// Modbus功能码映射
export const modbusFunctionCodes = {
    readCoils: 1,
    readDiscreteInputs: 2,
    readHoldingRegisters: 3,
    readInputRegisters: 4,
    writeSingleCoil: 5,
    writeSingleHoldingRegister: 6,
    writeMultipleCoils: 15,
    writeMultipleHoldingRegisters: 16,
};

// 读取指令类型
export const readInstructionTypes = [
    'readCoils',
    'readDiscreteInputs',
    'readHoldingRegisters',
    'readInputRegisters'
];

// 写入指令类型
export const writeInstructionTypes = [
    'writeSingleCoil',
    'writeSingleHoldingRegister',
    'writeMultipleCoils',
    'writeMultipleHoldingRegisters'
];

// 线圈相关指令类型（不需要数据类型）
export const coilInstructionTypes = [
    'readCoils',
    'writeSingleCoil',
    'writeMultipleCoils',
    'readDiscreteInputs'
];

// 寄存器相关指令类型（需要寄存器数目）
export const registerInstructionTypes = [
    'readHoldingRegisters',
    'readInputRegisters',
    'writeSingleHoldingRegister',
    'writeMultipleHoldingRegisters'
];
