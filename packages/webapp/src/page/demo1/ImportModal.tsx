import React, { useState, useRef } from 'react';
import {
    Modal,
    Button,
    message,
    Typography,
    Space,
    Progress,
    Alert,
} from 'antd';
import {
    DownloadOutlined,
    FolderOpenOutlined,
    UploadOutlined,
} from '@ant-design/icons';
import type { UploadFile } from 'antd';
import { type ChannelData } from './mockData';
import { exportTemplateToExcel } from './exportUtils';
import { IMPORT_CONFIG } from './importConfig';

const { Text } = Typography;

interface ImportModalProps {
    visible: boolean;
    onCancel: () => void;
    onImport: (channels: ChannelData[]) => void;
    existingChannelCount: number;
}

const ImportModal: React.FC<ImportModalProps> = ({
    visible,
    onCancel,
    onImport,
    existingChannelCount,
}) => {
    const [fileList, setFileList] = useState<UploadFile[]>([]);
    const [uploading, setUploading] = useState(false);
    const [validating, setValidating] = useState(false);
    const [progress, setProgress] = useState(0);
    const [errorMessage, setErrorMessage] = useState('');
    const fileInputRef = useRef<HTMLInputElement>(null);

    // 使用配置文件中的校验模式设置
    const USE_FRONTEND_VALIDATION = IMPORT_CONFIG.USE_FRONTEND_VALIDATION;

    // 重置状态
    const resetState = () => {
        setFileList([]);
        setUploading(false);
        setValidating(false);
        setProgress(0);
        setErrorMessage('');
    };

    // 下载模板
    const handleDownloadTemplate = () => {
        try {
            exportTemplateToExcel();
            message.success('模板下载成功');
        } catch {
            message.error('模板下载失败，请重试');
        }
    };


    // 手动选择文件
    const handleManualSelect = () => {
        if (fileInputRef.current) {
            fileInputRef.current.click();
        }
    };

    // 文件输入变化
    const handleFileInputChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        const file = event.target.files?.[0];
        if (file) {
            const isSupported = IMPORT_CONFIG.SUPPORTED_FILE_TYPES.some(ext => 
                file.name.toLowerCase().endsWith(ext.toLowerCase())
            );
            
            if (!isSupported) {
                message.error(`请选择支持的文件格式：${IMPORT_CONFIG.SUPPORTED_FILE_TYPES.join(', ')}`);
                return;
            }
            setFileList([file as unknown as UploadFile]);
            setErrorMessage('');
        }
    };

    // 解析文件（支持CSV和Excel）
    const parseFile = async (file: File): Promise<unknown[]> => {
        const isCsv = file.type === 'text/csv' || file.name.endsWith('.csv');

        if (isCsv) {
            // 解析CSV文件
            const content = await new Promise<string>((resolve, reject) => {
                const reader = new FileReader();
                reader.onload = (e) => resolve(e.target?.result as string);
                reader.onerror = reject;
                reader.readAsText(file, 'utf-8');
            });

            const lines = content.split('\n').filter(line => line.trim());
            if (lines.length < 2) return [];

            const headers = lines[0].split(',').map(h => h.trim());
            const data = [];

            for (let i = 1; i < lines.length; i++) {
                const values = lines[i].split(',').map(v => v.trim());
                // eslint-disable-next-line @typescript-eslint/no-explicit-any
                const row: any = {};
                headers.forEach((header, index) => {
                    row[header] = values[index] || '';
                });
                data.push(row);
            }

            return data;
        } else {
            // 解析Excel文件
            const XLSX = await import('xlsx');
            const data = await new Promise<unknown[]>((resolve, reject) => {
                const reader = new FileReader();
                reader.onload = (e) => {
                    try {
                        const workbook = XLSX.read(e.target?.result, { type: 'binary' });
                        const sheetName = workbook.SheetNames[0];
                        const worksheet = workbook.Sheets[sheetName];
                        const jsonData = XLSX.utils.sheet_to_json(worksheet);
                        resolve(jsonData);
                    } catch (error) {
                        reject(error);
                    }
                };
                reader.onerror = reject;
                reader.readAsBinaryString(file);
            });

            return data;
        }
    };

    // 模拟后端校验API
    const simulateBackendValidation = async (data: unknown[]): Promise<{ isValid: boolean; errorRow?: number; errorMessage?: string }> => {
        // 模拟API调用延迟
        await new Promise(resolve => setTimeout(resolve, 500));

        // 这里可以替换为真实的后端API调用
        // const response = await fetch('/api/validate-channels', {
        //     method: 'POST',
        //     headers: { 'Content-Type': 'application/json' },
        //     body: JSON.stringify({ channels: data })
        // });
        // return await response.json();

        // 模拟后端校验逻辑（与前端校验相同，但可以有不同的实现）
        return validateChannelData(data);
    };

    // 校验通道数据
    const validateChannelData = (data: unknown[], rowOffset: number = 1): { isValid: boolean; errorRow?: number; errorMessage?: string } => {
        for (let i = 0; i < data.length; i++) {
            const row = data[i] as unknown as ChannelData;
            const rowNumber = i + rowOffset + 1; // +1 因为CSV有标题行，+1 因为从1开始计数

            // 必填字段校验
            if (!row.channelName?.trim()) {
                return { isValid: false, errorRow: rowNumber, errorMessage: '通道名称不能为空' };
            }

            if (!row.linkType?.trim()) {
                return { isValid: false, errorRow: rowNumber, errorMessage: '链路类型不能为空' };
            }

            if (!row.serverId?.trim()) {
                return { isValid: false, errorRow: rowNumber, errorMessage: '服务器ID不能为空' };
            }

            if (!row.instructionType?.trim()) {
                return { isValid: false, errorRow: rowNumber, errorMessage: '指令类型不能为空' };
            }

            if (!row.registerAddress?.trim()) {
                return { isValid: false, errorRow: rowNumber, errorMessage: '寄存器地址不能为空' };
            }

            // 链路类型校验
            const validLinkTypes = ['serial', 'serial1', 'serial2', 'tcp'];
            if (!validLinkTypes.includes(row.linkType)) {
                return { isValid: false, errorRow: rowNumber, errorMessage: '链路类型无效' };
            }

            // 指令类型校验
            const validInstructionTypes = [
                'readCoils', 'readDiscreteInputs', 'readHoldingRegisters', 'readInputRegisters',
                'writeSingleCoil', 'writeSingleHoldingRegister', 'writeMultipleCoils', 'writeMultipleHoldingRegisters'
            ];
            if (!validInstructionTypes.includes(row.instructionType)) {
                return { isValid: false, errorRow: rowNumber, errorMessage: '指令类型无效' };
            }

            // 数据类型校验（对于寄存器相关指令）
            const registerInstructionTypes = [
                'readHoldingRegisters', 'readInputRegisters',
                'writeSingleHoldingRegister', 'writeMultipleHoldingRegisters'
            ];
            if (registerInstructionTypes.includes(row.instructionType)) {
                if (!row.dataType?.trim()) {
                    return { isValid: false, errorRow: rowNumber, errorMessage: '数据类型不能为空' };
                }
                const validDataTypes = ['INT16', 'INT32', 'INT64', 'Float32', 'Float64', 'ASCII', 'HEX'];
                if (!validDataTypes.includes(row.dataType)) {
                    return { isValid: false, errorRow: rowNumber, errorMessage: '数据类型无效' };
                }
            }

            // 寄存器地址校验
            const registerAddress = parseInt(row.registerAddress);
            if (isNaN(registerAddress) || registerAddress < 0 || registerAddress > 65535) {
                return { isValid: false, errorRow: rowNumber, errorMessage: '寄存器地址无效' };
            }

            // 服务器ID校验
            const serverId = parseInt(row.serverId);
            if (isNaN(serverId) || serverId < 1 || serverId > 255) {
                return { isValid: false, errorRow: rowNumber, errorMessage: '服务器ID无效' };
            }
        }

        return { isValid: true };
    };

    // 上传文件
    const handleUpload = async () => {
        if (fileList.length === 0) {
            message.error('请先选择文件');
            return;
        }

        const file = fileList[0];
        setUploading(true);
        setProgress(0);

        try {
            // 模拟上传进度
            const progressInterval = setInterval(() => {
                setProgress(prev => {
                    if (prev >= 90) {
                        clearInterval(progressInterval);
                        return 90;
                    }
                    return prev + 10;
                });
            }, 200);

            // 解析文件（支持CSV和Excel）
            const csvData = await parseFile(file as unknown as File);

            clearInterval(progressInterval);
            setProgress(100);

            if (csvData.length === 0) {
                setErrorMessage('文件格式错误，请检查文件内容');
                setUploading(false);
                return;
            }

            // 检查数量限制
            if (csvData.length + existingChannelCount > IMPORT_CONFIG.MAX_CHANNEL_COUNT) {
                setErrorMessage(`导入失败，所添加通道数超出上限，最大允许添加${IMPORT_CONFIG.MAX_CHANNEL_COUNT}个通道`);
                setUploading(false);
                return;
            }

            // 开始校验
            setValidating(true);
            setUploading(false);

            // 模拟校验过程
            await new Promise(resolve => setTimeout(resolve, 1000));

            let validation;
            if (USE_FRONTEND_VALIDATION) {
                // 前端校验
                validation = validateChannelData(csvData);
                if (!validation.isValid) {
                    setErrorMessage(`导入失败，第 ${validation.errorRow} 行错误，请检查参数`);
                    setValidating(false);
                    return;
                }
            } else {
                // 后端校验 - 这里可以调用后端API
                try {
                    // 模拟后端校验API调用
                    const response = await simulateBackendValidation(csvData);
                    if (!response.isValid) {
                        setErrorMessage(`导入失败，第 ${response.errorRow} 行错误：${response.errorMessage}`);
                        setValidating(false);
                        return;
                    }
                } catch {
                    setErrorMessage('后端校验失败，请重试');
                    setValidating(false);
                    return;
                }
            }

            // 转换数据格式
            // eslint-disable-next-line @typescript-eslint/no-explicit-any
            const channels: ChannelData[] = csvData.map((row: any, index) => ({
                id: `import_${Date.now()}_${index}`,
                channelName: row.channelName,
                linkType: row.linkType,
                serverId: row.serverId,
                instructionType: row.instructionType,
                dataType: row.dataType,
                byteOrder: row.byteOrder,
                registerAddress: row.registerAddress,
                registerValue: row.registerValue,
                registerCount: row.registerCount,
                isSigned: row.isSigned === 'true',
                decimalPlaces: row.decimalPlaces ? parseInt(row.decimalPlaces) : undefined,
                isApplied: false,
            }));

            message.success(`成功导入 ${channels.length} 个通道`);
            onImport(channels);
            resetState();
            onCancel();

        } catch (error) {
            console.error('上传失败:', error);
            setErrorMessage('文件上传失败，请重试');
            setUploading(false);
            setValidating(false);
        }
    };

    // 关闭确认
    const handleClose = () => {
        if (uploading || validating) {
            Modal.confirm({
                title: '正在导入中，请稍等',
                content: '确认关闭？',
                okText: '确认',
                cancelText: '取消',
                onOk: () => {
                    resetState();
                    onCancel();
                },
            });
        } else {
            resetState();
            onCancel();
        }
    };

    return (
        <Modal
            title="导入通道"
            open={visible}
            onCancel={handleClose}
            footer={null}
            width={600}
            destroyOnClose
        >
            <div style={{ padding: '20px 0' }}>
                <Space direction="vertical" size="large" style={{ width: '100%' }}>
                    {/* 模板下载 */}
                    <div>
                        <Text strong>1. 下载模板</Text>
                        <div style={{ marginTop: 8 }}>
                            <Button
                                icon={<DownloadOutlined />}
                                onClick={handleDownloadTemplate}
                            >
                                下载模板
                            </Button>
                        </div>
                    </div>

                    {/* 文件选择 */}
                    <div>
                        <Text strong>2. 选择文件</Text>
                        <div style={{ marginTop: 8 }}>
                            <Space>
                                <Button
                                    icon={<FolderOpenOutlined />}
                                    onClick={handleManualSelect}
                                    disabled={uploading || validating}
                                >
                                    选择文件
                                </Button>
                                <input
                                    ref={fileInputRef}
                                    type="file"
                                    accept={IMPORT_CONFIG.SUPPORTED_FILE_TYPES.join(',')}
                                    style={{ display: 'none' }}
                                    onChange={handleFileInputChange}
                                />
                                {fileList.length > 0 && (
                                    <Text type="secondary">
                                        已选择: {(fileList[0] as unknown as UploadFile).name}
                                    </Text>
                                )}
                            </Space>
                        </div>
                    </div>

                    {/* 上传按钮 */}
                    <div>
                        <Button
                            type="primary"
                            icon={<UploadOutlined />}
                            onClick={handleUpload}
                            disabled={fileList.length === 0 || uploading || validating}
                            loading={uploading}
                        >
                            上传
                        </Button>
                    </div>

                    {/* 进度条 */}
                    {(uploading || validating) && (
                        <div>
                            <Progress
                                percent={progress}
                                status={validating ? 'active' : 'normal'}
                            />
                            <Text type="secondary">
                                {validating ? '导入校验中，请勿关闭' : '上传中...'}
                            </Text>
                        </div>
                    )}

                    {/* 错误信息 */}
                    {errorMessage && (
                        <Alert
                            message="导入失败"
                            description={errorMessage}
                            type="error"
                            showIcon
                        />
                    )}
                </Space>
            </div>
        </Modal>
    );
};

export default ImportModal;
