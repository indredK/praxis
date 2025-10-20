import React, { useState, useEffect } from "react";
import _ from "lodash";
import {
    Table,
    Button,
    Space,
    Input,
    message,
    Card,
    Typography,
    Row,
    Col,
    Checkbox,
    Modal,
} from "antd";
import {
    EditOutlined,
    DeleteOutlined,
    SearchOutlined,
    ExportOutlined,
    CopyOutlined,
    DeleteColumnOutlined,
    ImportOutlined,
} from "@ant-design/icons";
import type { ColumnsType } from "antd/es/table";
import ChannelModal from "./ChannelModal";
import ImportModal from "./ImportModal";
import { exportChannelsToExcel } from "./exportUtils";

// 定义Channel接口
interface Channel {
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

const { Title } = Typography;

const ChannelTable: React.FC = () => {
    const [data, setData] = useState<Channel[]>([]); // 当前页显示的数据
    const [loading, setLoading] = useState(false);
    const [searchText, setSearchText] = useState("");
    const [selectedRowKeys, setSelectedRowKeys] = useState<React.Key[]>([]);
    const [modalVisible, setModalVisible] = useState(false);
    const [editingRecord, setEditingRecord] = useState<Channel | null>(null);
    const [importModalVisible, setImportModalVisible] = useState(false);

    // 翻页状态
    const [pagination, setPagination] = useState({
        current: 1,
        pageSize: 10,
        total: 0,
        totalPages: 0
    });

    // 工具函数：构建CGI请求参数
    const buildCgiRequest = (base: string, limit: number, start: number) =>
        _.merge(
            { id: 47, execute: 1, core: "yruo_firewall_iorules", function: "get" },
            { values: [{ base, limit, start }] }
        );

    // 工具函数：安全提取响应数据
    const extractResponseData = (result: Record<string, unknown>) => ({
        serverData: _.get(result, 'get[0].value.server', []) as Channel[],
        serverCount: _.get(result, 'get[0].value.server_count', 0) as number
    });

    // 工具函数：验证响应数据
    const isValidResponse = (serverData: Channel[], serverCount: number) =>
        !_.isEmpty(serverData) || serverCount > 0;

    // 从API获取通道数据 - 使用lodash优化
    const fetchChannels = async (page: number = pagination.current, pageSize: number = pagination.pageSize) => {
        setLoading(true);

        try {
            // 构建请求参数
            const requestBody = JSON.stringify(
                buildCgiRequest("yruo_firewall_channelSettings", pageSize, (page - 1) * pageSize)
            );

            const response = await fetch('/cgi', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: requestBody
            });

            const result = await response.json();

            // 提取和验证数据
            const { serverData, serverCount } = extractResponseData(result);

            if (!isValidResponse(serverData, serverCount)) {
                message.error('获取通道数据失败：响应格式不正确');
                return;
            }

            // 更新数据和翻页信息
            setData(serverData);
            setPagination(_.merge(pagination, {
                current: page,
                pageSize: pageSize,
                total: serverCount,
                totalPages: Math.ceil(serverCount / pageSize)
            }));

        } catch (error) {
            console.error('获取通道数据失败:', error);
            message.error('获取通道数据失败，请检查网络连接');
        } finally {
            setLoading(false);
        }
    };

    // 组件挂载时获取数据
    useEffect(() => {
        fetchChannels();
    }, []); // eslint-disable-line react-hooks/exhaustive-deps

    // 模拟API请求
    const simulateApiCall = async (action: string) => {
        setLoading(true);
        await new Promise((resolve) => setTimeout(resolve, 500));
        setLoading(false);
        message.success(`${action}操作成功`);
    };

    // 编辑通道
    const handleEdit = (record: Channel) => {
        setEditingRecord(record);
        setModalVisible(true);
    };

    // 检查选中通道的应用状态
    const checkSelectedChannelsStatus = () => {
        const selectedChannels = data.filter(item => selectedRowKeys.includes(item.id));
        const hasAppliedChannels = selectedChannels.some(channel => channel.isApplied);
        return { selectedChannels, hasAppliedChannels };
    };

    // 单个删除通道
    const handleDelete = async (record: Channel) => {
        // 检查通道是否正在应用中
        if (record.isApplied) {
            Modal.warning({
                title: '无法删除',
                content: '存在正在应用中的通道，无法删除',
                okText: '确定',
            });
            return;
        }

        // 如果通道未在应用中，显示确认删除提示
        Modal.confirm({
            title: '确认删除',
            content: '是否确认删除？',
            okText: '确认',
            cancelText: '取消',
            onOk: async () => {
                await simulateApiCall("删除");
                setData(data.filter((item) => item.id !== record.id));
                // 如果删除的通道在选中列表中，需要从选中列表中移除
                if (selectedRowKeys.includes(record.id)) {
                    setSelectedRowKeys(selectedRowKeys.filter(key => key !== record.id));
                }
            },
        });
    };

    // 批量删除
    const handleBatchDelete = async () => {
        if (selectedRowKeys.length === 0) {
            message.warning("请选择要删除的通道");
            return;
        }

        const { hasAppliedChannels } = checkSelectedChannelsStatus();

        // 如果存在正在应用中的通道
        if (hasAppliedChannels) {
            Modal.warning({
                title: '无法删除',
                content: '存在正在应用中的通道，无法删除',
                okText: '确定',
            });
            return;
        }

        // 如果所有选中的通道都未在应用中，显示确认删除提示
        Modal.confirm({
            title: '确认删除',
            content: '是否确认删除？',
            okText: '确认',
            cancelText: '取消',
            onOk: async () => {
                await simulateApiCall("批量删除");
                setData(data.filter((item) => !selectedRowKeys.includes(item.id)));
                setSelectedRowKeys([]); // 清空选中状态
            },
        });
    };

    // 导出
    const handleExport = async () => {
        try {
            await simulateApiCall("导出");
            const fileName = exportChannelsToExcel(data);
            message.success(`导出成功：${fileName}`);
        } catch {
            message.error('导出失败，请重试');
        }
    };

    // 新增通道（空白编辑弹框）
    const handleAdd = () => {
        setEditingRecord(null);
        setModalVisible(true);
    };

    // 导入通道
    const handleImport = () => {
        setImportModalVisible(true);
    };

    // 处理导入的通道数据
    const handleImportChannels = (channels: Channel[]) => {
        setData([...data, ...channels]);
        message.success(`成功导入 ${channels.length} 个通道`);
    };

    // 搜索功能 - 使用lodash debounce优化
    const handleSearch = _.debounce(() => {
        // 重置到第一页进行搜索
        fetchChannels(1, pagination.pageSize);
    }, 300);

    // 全选/取消全选处理 - 使用lodash优化
    const handleSelectAll = (checked: boolean) => {
        const newSelectedKeys = checked
            ? _.map(data, 'id')
            : [];
        setSelectedRowKeys(newSelectedKeys);
    };

    // 检查是否全选 - 使用lodash优化
    const isAllSelected = data.length > 0 && _.every(data, item => _.includes(selectedRowKeys, item.id));
    const isIndeterminate = selectedRowKeys.length > 0 && !isAllSelected;

    const columns: ColumnsType<Channel> = [
        {
            title: (
                <Checkbox
                    checked={isAllSelected}
                    indeterminate={isIndeterminate}
                    onChange={(e) => handleSelectAll(e.target.checked)}
                />
            ),
            dataIndex: "id",
            width: 50,
            render: (_, record) => (
                <Checkbox
                    checked={selectedRowKeys.includes(record.id)}
                    onChange={(e) => {
                        if (e.target.checked) {
                            setSelectedRowKeys([...selectedRowKeys, record.id]);
                        } else {
                            setSelectedRowKeys(
                                selectedRowKeys.filter((key) => key !== record.id)
                            );
                        }
                    }}
                />
            ),
        },
        {
            title: "通道名称",
            dataIndex: "channelName",
            key: "channelName",
            width: 120,
        },
        {
            title: "链路类型",
            dataIndex: "linkType",
            key: "linkType",
            width: 120,
            render: (value) => {
                const linkTypeMap: Record<string, string> = {
                    'serial': 'Serial',
                    'serial1': 'Serial',
                    'serial2': 'Serial',
                    'tcp': 'TCP'
                };
                return linkTypeMap[value] || value;
            }
        },
        {
            title: "通道类型",
            dataIndex: "instructionType",
            key: "channelType",
            width: 120,
            render: (value) => {
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
                return channelTypeMap[value] || value;
            }
        },
        {
            title: "指令类型",
            dataIndex: "instructionType",
            key: "instructionType",
            width: 150,
            render: () => {
                return '保存寄存器';
            }
        },
        {
            title: "数据类型",
            dataIndex: "dataType",
            key: "dataType",
            width: 100,
        },
        {
            title: "寄存器地址",
            dataIndex: "registerAddress",
            key: "registerAddress",
            width: 120,
        },
        {
            title: "寄存器数目/值",
            dataIndex: "registerCount",
            key: "registerCount",
            width: 150,
            render: (_, record) => {
                if (record.registerValue) {
                    return record.registerValue;
                }
                return record.registerCount || '-';
            }
        },
        {
            title: "操作",
            key: "action",
            width: 120,
            render: (_, record) => (
                <Space size="small">
                    <Button
                        type="link"
                        icon={<EditOutlined />}
                        onClick={() => handleEdit(record)}
                        size="small"
                    >
                        编辑
                    </Button>
                    <Button
                        type="link"
                        danger
                        icon={<DeleteOutlined />}
                        size="small"
                        onClick={() => handleDelete(record)}
                    >
                        删除
                    </Button>
                </Space>
            ),
        },
    ];

    return (
        <Card>
            <div style={{ marginBottom: 16 }}>
                <Title level={4} style={{ margin: 0 }}>
                    <span
                        style={{
                            display: "inline-block",
                            width: 4,
                            height: 20,
                            backgroundColor: "#1890ff",
                            marginRight: 8,
                            verticalAlign: "middle",
                        }}
                    ></span>
                    通道设置
                </Title>
            </div>

            <Row justify="space-between" align="middle" style={{ marginBottom: 16 }}>
                <Col>
                    <Space>
                        <Button
                            type="primary"
                            icon={<ImportOutlined />}
                            onClick={handleImport}
                        >
                            导入
                        </Button>
                        <Button
                            type="primary"
                            icon={<ExportOutlined />}
                            onClick={handleExport}
                        >
                            导出
                        </Button>
                        <Button
                            type="primary"
                            icon={<CopyOutlined />}
                            onClick={handleAdd}
                        >
                            新增
                        </Button>
                        <Button
                            danger
                            icon={<DeleteColumnOutlined />}
                            onClick={handleBatchDelete}
                            disabled={selectedRowKeys.length === 0}
                        >
                            批量删除
                        </Button>
                    </Space>
                </Col>
                <Col>
                    <Space>
                        <Input
                            placeholder="通道名称"
                            prefix={<SearchOutlined />}
                            value={searchText}
                            onChange={(e) => setSearchText(e.target.value)}
                            onPressEnter={handleSearch}
                            style={{ width: 200 }}
                        />
                        <Button
                            type="primary"
                            icon={<SearchOutlined />}
                            onClick={handleSearch}
                        >
                            搜索
                        </Button>
                    </Space>
                </Col>
            </Row>

            <Table
                columns={columns}
                dataSource={data}
                rowKey="id"
                loading={loading}
                pagination={{
                    current: pagination.current,
                    pageSize: pagination.pageSize,
                    total: pagination.total,
                    showSizeChanger: true,
                    showQuickJumper: true,
                    showTotal: (total, range) =>
                        `第 ${range[0]}-${range[1]} 条/共 ${total} 条`,
                    onChange: (page, pageSize) => {
                        fetchChannels(page, pageSize);
                    },
                    onShowSizeChange: (_current, size) => {
                        fetchChannels(1, size);
                    }
                }}
                scroll={{ x: 1000 }}
                size="small"
            />


            <ChannelModal
                visible={modalVisible}
                onCancel={() => setModalVisible(false)}
                onSubmit={() => {

                    setModalVisible(false);
                }}
                initialValues={editingRecord}
            />

            <ImportModal
                visible={importModalVisible}
                onCancel={() => setImportModalVisible(false)}
                onImport={handleImportChannels}
                existingChannelCount={data.length}
            />
        </Card>
    );
};

export default ChannelTable;
