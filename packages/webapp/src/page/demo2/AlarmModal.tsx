import React, { useEffect, useState } from "react";
import {
  Modal,
  Form,
  Input,
  Select,
  Checkbox,
  Button,
  InputNumber,
  message,
} from "antd";
import type { AlarmData } from "./mockData";
import {
  conditionOptions,
  alarmMethodOptions,
  channelNameOptions,
} from "./mockData";
import {
  fetchPhoneGroups,
  fetchEmailGroups,
  searchPhoneGroups,
  searchEmailGroups,
  type GroupData,
} from "./apiService";

const { TextArea } = Input;

interface AlarmModalProps {
  visible: boolean;
  onCancel: () => void;
  onSubmit: (values: AlarmData) => void;
  initialValues?: AlarmData | null;
}

const AlarmModal: React.FC<AlarmModalProps> = ({
  visible,
  onCancel,
  onSubmit,
  initialValues,
}) => {
  const [form] = Form.useForm();
  const [phoneGroups, setPhoneGroups] = useState<GroupData[]>([]);
  const [emailGroups, setEmailGroups] = useState<GroupData[]>([]);
  const [phoneGroupLoading, setPhoneGroupLoading] = useState(false);
  const [emailGroupLoading, setEmailGroupLoading] = useState(false);

  // 监听告警方式变化
  const alarmMethod = Form.useWatch('alarmMethod', form);

  useEffect(() => {
    if (visible) {
      if (initialValues) {
        form.setFieldsValue(initialValues);
      } else {
        form.resetFields();
        // 设置默认值
        form.setFieldsValue({
          condition: "小于(<)",
          minThreshold: 0,
          alarmMethod: ["短信", "邮箱"],
          continuousAlarm: false,
          normalAlarmContent: "提示:$YEAR/$MON/$DAY $TIME,从通道$NAME的地址$ADDRESS 读取到正常数据$VALUE。(异常范围是$CONDITION)",
          abnormalAlarmContent: "提示:$YEAR/$MON/$DAY $TIME,从通道$NAME的地址$ADDRESS 读取到异常数据$VALUE。(异常范围是$CONDITION)",
        });
      }
      // 加载群组数据
      loadPhoneGroups();
      loadEmailGroups();
    }
  }, [visible, initialValues, form]);

  // 加载电话群组
  const loadPhoneGroups = async () => {
    setPhoneGroupLoading(true);
    try {
      const groups = await fetchPhoneGroups();
      setPhoneGroups(groups);
    } catch (error) {
      console.error("加载电话群组失败:", error);
      message.error("加载电话群组失败");
    } finally {
      setPhoneGroupLoading(false);
    }
  };

  // 加载邮箱群组
  const loadEmailGroups = async () => {
    setEmailGroupLoading(true);
    try {
      const groups = await fetchEmailGroups();
      setEmailGroups(groups);
    } catch (error) {
      console.error("加载邮箱群组失败:", error);
      message.error("加载邮箱群组失败");
    } finally {
      setEmailGroupLoading(false);
    }
  };

  // 搜索电话群组
  const handlePhoneGroupSearch = async (value: string) => {
    try {
      const groups = await searchPhoneGroups(value);
      setPhoneGroups(groups);
    } catch (error) {
      console.error("搜索电话群组失败:", error);
      message.error("搜索电话群组失败");
    }
  };

  // 搜索邮箱群组
  const handleEmailGroupSearch = async (value: string) => {
    try {
      const groups = await searchEmailGroups(value);
      setEmailGroups(groups);
    } catch (error) {
      console.error("搜索邮箱群组失败:", error);
      message.error("搜索邮箱群组失败");
    }
  };

  const handleSubmit = async () => {
    try {
      const values = await form.validateFields();
      onSubmit(values);
    } catch (error) {
      console.error("表单验证失败:", error);
    }
  };

  return (
    <Modal
      title={initialValues ? "编辑告警设置" : "新增告警设置"}
      open={visible}
      onCancel={onCancel}
      width={800}
      footer={[
        <Button key="cancel" onClick={onCancel}>
          取消
        </Button>,
        <Button key="submit" type="primary" onClick={handleSubmit}>
          确认
        </Button>,
      ]}
      styles={{
        body: {
          height: '600px',
          overflowY: 'auto',
          padding: '16px 24px',
        }
      }}
    >
      <div style={{ borderTop: "1px dashed #d9d9d9", paddingTop: 16 }}>
        <Form
          form={form}
          layout="vertical"
          labelAlign="left"
          size="middle"
        >
          {/* 读取通道名称 */}
          <Form.Item
            label="读取通道名称"
            name="readChannelName"
            rules={[{ required: true, message: "请选择读取通道名称" }]}
          >
            <Select
              options={channelNameOptions}
              placeholder="请选择读取通道名称"
              showSearch
              filterOption={(input, option) =>
                (option?.label ?? '').toLowerCase().includes(input.toLowerCase())
              }
            />
          </Form.Item>

          {/* 条件 */}
          <Form.Item
            label="条件"
            name="condition"
            rules={[{ required: true, message: "请选择条件" }]}
          >
            <Select options={conditionOptions} />
          </Form.Item>

          {/* 最小阈值 */}
          <Form.Item
            label="最小阈值"
            name="minThreshold"
            rules={[{ required: true, message: "请输入最小阈值" }]}
          >
            <InputNumber
              style={{ width: '100%' }}
              placeholder="请输入最小阈值"
              min={0}
            />
          </Form.Item>

          {/* 告警方式 */}
          <Form.Item
            label="告警方式"
            name="alarmMethod"
            rules={[{ required: true, message: "请选择告警方式" }]}
          >
            <Checkbox.Group options={alarmMethodOptions} />
          </Form.Item>

          {/* 电话群组 - 仅当选择短信时显示 */}
          {alarmMethod?.includes('短信') && (
            <Form.Item
              label="电话群组"
              name="phoneGroup"
              rules={[{ required: true, message: "请选择电话群组" }]}
            >
              <Select
                placeholder="请选择电话群组"
                loading={phoneGroupLoading}
                showSearch
                onSearch={handlePhoneGroupSearch}
                filterOption={false}
                options={phoneGroups.map(group => ({
                  label: group.name,
                  value: group.name,
                  description: group.description,
                }))}
              />
            </Form.Item>
          )}

          {/* 邮箱群组 - 仅当选择邮箱时显示 */}
          {alarmMethod?.includes('邮箱') && (
            <Form.Item
              label="邮箱群组"
              name="emailGroup"
              rules={[{ required: true, message: "请选择邮箱群组" }]}
            >
              <Select
                placeholder="请选择邮箱群组"
                loading={emailGroupLoading}
                showSearch
                onSearch={handleEmailGroupSearch}
                filterOption={false}
                options={emailGroups.map(group => ({
                  label: group.name,
                  value: group.name,
                  description: group.description,
                }))}
              />
            </Form.Item>
          )}

          {/* 正常告警内容 */}
          <Form.Item
            label="正常告警内容"
            name="normalAlarmContent"
          >
            <TextArea
              rows={3}
              placeholder="请输入正常告警内容"
            />
          </Form.Item>

          {/* 异常告警内容 */}
          <Form.Item
            label="异常告警内容"
            name="abnormalAlarmContent"
          >
            <TextArea
              rows={3}
              placeholder="请输入异常告警内容"
            />
          </Form.Item>

          {/* 连续告警 */}
          <Form.Item
            label="连续告警"
            name="continuousAlarm"
            valuePropName="checked"
          >
            <Checkbox>连续告警</Checkbox>
          </Form.Item>

          {/* 写入通道名称 */}
          <Form.Item
            label="写入通道名称"
            name="writeChannelName"
          >
            <Select
              options={channelNameOptions}
              placeholder="请选择写入通道名称（可选）"
              allowClear
              showSearch
              filterOption={(input, option) =>
                (option?.label ?? '').toLowerCase().includes(input.toLowerCase())
              }
            />
          </Form.Item>
        </Form>
      </div>
    </Modal>
  );
};

export default AlarmModal;
