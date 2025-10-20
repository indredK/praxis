import React, { useState } from "react";
import {
  Table,
  Button,
  Space,
  Input,
  Popconfirm,
  message,
  Card,
  Typography,
  Row,
  Col,
  Checkbox,
} from "antd";
import {
  EditOutlined,
  DeleteOutlined,
  SearchOutlined,
  ExportOutlined,
  CopyOutlined,
  DeleteColumnOutlined,
} from "@ant-design/icons";
import type { ColumnsType } from "antd/es/table";
import { type AlarmData, mockAlarmData } from "./mockData";
import AlarmModal from "./AlarmModal";

const { Title } = Typography;

const AlarmTable: React.FC = () => {
  const [data, setData] = useState<AlarmData[]>(mockAlarmData);
  const [loading, setLoading] = useState(false);
  const [searchText, setSearchText] = useState("");
  const [selectedRowKeys, setSelectedRowKeys] = useState<React.Key[]>([]);
  const [modalVisible, setModalVisible] = useState(false);
  const [editingRecord, setEditingRecord] = useState<AlarmData | null>(null);

  // 模拟API请求
  const simulateApiCall = async (action: string) => {
    setLoading(true);
    await new Promise((resolve) => setTimeout(resolve, 500));
    setLoading(false);
    message.success(`${action}操作成功`);
  };

  // 新增告警设置
  const handleAdd = () => {
    setEditingRecord(null);
    setModalVisible(true);
  };

  // 编辑告警设置
  const handleEdit = (record: AlarmData) => {
    setEditingRecord(record);
    setModalVisible(true);
  };

  // 删除告警设置
  const handleDelete = async (record: AlarmData) => {
    await simulateApiCall("删除");
    setData(data.filter((item) => item.id !== record.id));
  };

  // 批量删除
  const handleBatchDelete = async () => {
    if (selectedRowKeys.length === 0) {
      message.warning("请选择要删除的告警设置");
      return;
    }
    await simulateApiCall("批量删除");
    setData(data.filter((item) => !selectedRowKeys.includes(item.id)));
    setSelectedRowKeys([]);
  };

  // 导出
  const handleExport = async () => {
    await simulateApiCall("导出");
  };

  // 批量添加
  const handleBatchAdd = () => {
    message.info("批量添加功能待实现");
  };

  // 搜索
  const filteredData = data.filter((item) =>
    item.readChannelName.toLowerCase().includes(searchText.toLowerCase())
  );

  const columns: ColumnsType<AlarmData> = [
    {
      title: "",
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
      title: "读取通道名称",
      dataIndex: "readChannelName",
      key: "readChannelName",
      width: 120,
    },
    {
      title: "条件",
      dataIndex: "condition",
      key: "condition",
      width: 100,
      render: (condition: string, record: AlarmData) => {
        const conditionMap: Record<string, string> = {
          '小于(<)': '<',
          '大于(>)': '>',
          '等于(=)': '=',
          '不等于(!=)': '!=',
          '小于等于(<=)': '<=',
          '大于等于(>=)': '>=',
        };
        const symbol = conditionMap[condition] || condition;
        return `${symbol} ${record.minThreshold}`;
      },
    },
    {
      title: "告警方式",
      dataIndex: "alarmMethod",
      key: "alarmMethod",
      width: 100,
      render: (methods: string[]) => {
        // 只显示第一个告警方式
        return methods[0] || '-';
      },
    },
    {
      title: "写入通道名称",
      dataIndex: "writeChannelName",
      key: "writeChannelName",
      width: 120,
      render: (value: string) => value || '-',
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
          <Popconfirm
            title="确定要删除这个告警设置吗？"
            onConfirm={() => handleDelete(record)}
            okText="确定"
            cancelText="取消"
          >
            <Button type="link" danger icon={<DeleteOutlined />} size="small">
              删除
            </Button>
          </Popconfirm>
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
          告警设置
        </Title>
      </div>

      <Row justify="space-between" align="middle" style={{ marginBottom: 16 }}>
        <Col>
          <Space>
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
              onClick={handleBatchAdd}
            >
              批量添加
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
          <Input
            placeholder="读取通道名称"
            prefix={<SearchOutlined />}
            value={searchText}
            onChange={(e) => setSearchText(e.target.value)}
            style={{ width: 200 }}
          />
        </Col>
      </Row>

      <Table
        columns={columns}
        dataSource={filteredData}
        rowKey="id"
        loading={loading}
        pagination={{
          current: 1,
          pageSize: 10,
          total: filteredData.length,
          showSizeChanger: true,
          showQuickJumper: true,
          showTotal: (total, range) =>
            `第 ${range[0]}-${range[1]} 条/共 ${total} 条`,
        }}
        scroll={{ x: 800 }}
        size="small"
      />

      <div style={{ marginTop: 16 }}>
        <Button type="primary" onClick={handleAdd}>
          新增告警设置
        </Button>
      </div>

      <AlarmModal
        visible={modalVisible}
        onCancel={() => setModalVisible(false)}
        onSubmit={(values) => {
          if (editingRecord) {
            // 编辑
            setData(
              data.map((item) =>
                item.id === editingRecord.id ? { ...item, ...values } : item
              )
            );
          } else {
            // 新增
            const newRecord = {
              ...values,
              id: Date.now().toString(),
            };
            setData([...data, newRecord]);
          }
          setModalVisible(false);
        }}
        initialValues={editingRecord}
      />
    </Card>
  );
};

export default AlarmTable;
