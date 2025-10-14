import * as XLSX from 'xlsx';
import { type ChannelData } from './mockData';

// 设备型号配置
const DEVICE_MODEL = 'UR35';
const DEVICE_VERSION = '35.3.0.10-a1-2';

// 生成导出文件名
export const generateExportFileName = (): string => {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');

    return `${DEVICE_MODEL}-${year}${month}${day}-${hours}${minutes}-${DEVICE_VERSION}-modbus_client.xlsx`;
};

// 转换通道数据为Excel格式
const convertChannelDataToExcel = (channels: ChannelData[]) => {
    return channels.map((channel, index) => ({
        '序号': index + 1,
        '通道名称': channel.channelName,
        '链路类型': getLinkTypeDisplay(channel.linkType),
        '服务器ID': channel.serverId,
        'IP地址': channel.ipAddress || '',
        '端口': channel.port || '',
        '通道类型': getChannelTypeDisplay(channel.instructionType),
        '指令类型': getInstructionTypeDisplay(channel.instructionType),
        '数据类型': channel.dataType || '',
        '字节顺序': channel.byteOrder || '',
        '寄存器地址': channel.registerAddress,
        '寄存器数目/值': channel.registerValue || channel.registerCount || '',
        '是否带符号': channel.isSigned ? '是' : '否',
        '小数位数': channel.decimalPlaces || '',
        '应用状态': channel.isApplied ? '正在应用中' : '未在应用中',
    }));
};

// 获取链路类型显示名称
const getLinkTypeDisplay = (linkType: string): string => {
    const linkTypeMap: Record<string, string> = {
        'serial': 'Serial',
        'serial1': 'Serial1',
        'serial2': 'Serial2',
        'tcp': 'TCP'
    };
    return linkTypeMap[linkType] || linkType;
};

// 获取通道类型显示名称
const getChannelTypeDisplay = (instructionType: string): string => {
    const channelTypeMap: Record<string, string> = {
        'readCoils': '读取',
        'readDiscreteInputs': '读取',
        'readHoldingRegisters': '读取',
        'readInputRegisters': '读取',
        'writeSingleCoil': '写入',
        'writeSingleHoldingRegister': '写入',
        'writeMultipleCoils': '写入',
        'writeMultipleHoldingRegisters': '写入'
    };
    return channelTypeMap[instructionType] || instructionType;
};

// 获取指令类型显示名称
const getInstructionTypeDisplay = (instructionType: string): string => {
    const instructionTypeMap: Record<string, string> = {
        'readCoils': '读线圈',
        'readDiscreteInputs': '读离散输入',
        'readHoldingRegisters': '读保持寄存器',
        'readInputRegisters': '读输入寄存器',
        'writeSingleCoil': '写单个线圈',
        'writeSingleHoldingRegister': '写单个保持寄存器',
        'writeMultipleCoils': '写多个线圈',
        'writeMultipleHoldingRegisters': '写多个保持寄存器'
    };
    return instructionTypeMap[instructionType] || instructionType;
};

// 导出通道数据到Excel
export const exportChannelsToExcel = (channels: ChannelData[]): void => {
    try {
        // 转换数据
        const excelData = convertChannelDataToExcel(channels);

        // 创建工作簿
        const workbook = XLSX.utils.book_new();

        // 创建工作表
        const worksheet = XLSX.utils.json_to_sheet(excelData);

        // 设置列宽
        const columnWidths = [
            { wch: 8 },   // 序号
            { wch: 15 },  // 通道名称
            { wch: 12 },  // 链路类型
            { wch: 10 },  // 服务器ID
            { wch: 15 },  // IP地址
            { wch: 8 },   // 端口
            { wch: 12 },  // 通道类型
            { wch: 18 },  // 指令类型
            { wch: 12 },  // 数据类型
            { wch: 12 },  // 字节顺序
            { wch: 15 },  // 寄存器地址
            { wch: 18 },  // 寄存器数目/值
            { wch: 12 },  // 是否带符号
            { wch: 10 },  // 小数位数
            { wch: 15 },  // 应用状态
        ];
        worksheet['!cols'] = columnWidths;

        // 添加工作表到工作簿
        XLSX.utils.book_append_sheet(workbook, worksheet, '通道列表');

        // 生成文件名
        const fileName = generateExportFileName();

        // 导出文件
        XLSX.writeFile(workbook, fileName);

        // return fileName;
    } catch (error) {
        console.error('导出Excel失败:', error);
        throw new Error('导出失败，请重试');
    }
};

// 导出模板到Excel
export const exportTemplateToExcel = (): void => {
    try {
        const templateData = [
            {
                '序号': 1,
                '通道名称': '示例通道1',
                '链路类型': 'Serial',
                '服务器ID': '1',
                'IP地址': '',
                '端口': '',
                '通道类型': '写入',
                '指令类型': '写单个保持寄存器',
                '数据类型': 'INT16',
                '字节顺序': 'AB',
                '寄存器地址': '40000',
                '寄存器数目/值': '100',
                '是否带符号': '否',
                '小数位数': '0',
                '应用状态': '未在应用中',
            },
            {
                '序号': 2,
                '通道名称': '示例通道2',
                '链路类型': 'Serial',
                '服务器ID': '1',
                'IP地址': '',
                '端口': '',
                '通道类型': '读取',
                '指令类型': '读保持寄存器',
                '数据类型': 'INT16',
                '字节顺序': 'AB',
                '寄存器地址': '40001',
                '寄存器数目/值': '1',
                '是否带符号': '否',
                '小数位数': '0',
                '应用状态': '未在应用中',
            }
        ];

        // 创建工作簿
        const workbook = XLSX.utils.book_new();

        // 创建工作表
        const worksheet = XLSX.utils.json_to_sheet(templateData);

        // 设置列宽
        const columnWidths = [
            { wch: 8 },   // 序号
            { wch: 15 },  // 通道名称
            { wch: 12 },  // 链路类型
            { wch: 10 },  // 服务器ID
            { wch: 15 },  // IP地址
            { wch: 8 },   // 端口
            { wch: 12 },  // 通道类型
            { wch: 18 },  // 指令类型
            { wch: 12 },  // 数据类型
            { wch: 12 },  // 字节顺序
            { wch: 15 },  // 寄存器地址
            { wch: 18 },  // 寄存器数目/值
            { wch: 12 },  // 是否带符号
            { wch: 10 },  // 小数位数
            { wch: 15 },  // 应用状态
        ];
        worksheet['!cols'] = columnWidths;

        // 添加工作表到工作簿
        XLSX.utils.book_append_sheet(workbook, worksheet, '通道模板');

        // 导出文件
        XLSX.writeFile(workbook, '通道导入模板.xlsx');

    } catch (error) {
        console.error('导出模板失败:', error);
        throw new Error('导出模板失败，请重试');
    }
};
