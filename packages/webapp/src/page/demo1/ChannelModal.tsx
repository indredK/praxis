import React, { useEffect, useState } from "react";
import {
  Modal,
  Form,
  Input,
  Select,
  Checkbox,
  Button,
  Space,
  InputNumber,
  Divider
} from "antd";
import { PlayCircleOutlined } from "@ant-design/icons";
import type { ChannelData } from "./mockData";
import {
  linkTypeOptions,
  instructionTypeOptions,
  dataTypeOptions,
  byteOrderOptions,
  readInstructionTypes,
  writeInstructionTypes,
  coilInstructionTypes,
  registerInstructionTypes,
} from "./channelConfig";

const { TextArea } = Input;

interface ChannelModalProps {
  visible: boolean;
  onCancel: () => void;
  onSubmit: (values: ChannelData) => void;
  initialValues?: ChannelData | null;
}

const ChannelModal: React.FC<ChannelModalProps> = ({
  visible,
  onCancel,
  onSubmit,
  initialValues,
}) => {
  const [form] = Form.useForm();
  const [testResults, setTestResults] = useState<string>("");
  const [isTesting, setIsTesting] = useState(false);

  // 监听表单字段变化
  const linkType = Form.useWatch('linkType', form);
  const instructionType = Form.useWatch('instructionType', form);
  const dataType = Form.useWatch('dataType', form);

  // 当数据类型改变时，重置字节顺序和有符号值
  useEffect(() => {
    if (dataType && instructionType) {
      const isCoilInstruction = coilInstructionTypes.includes(instructionType);

      if (!isCoilInstruction) {
        const currentByteOrderOptions = byteOrderOptions[dataType as keyof typeof byteOrderOptions] || [];
        if (currentByteOrderOptions.length > 0) {
          const currentByteOrder = form.getFieldValue('byteOrder');
          if (!currentByteOrderOptions.find((option: { value: string }) => option.value === currentByteOrder)) {
            form.setFieldValue('byteOrder', currentByteOrderOptions[0].value);
          }
        }
      }

      // 更新有符号字段的值
      const getSignedDefaultValue = () => {
        if (!instructionType || !dataType) return false;
        if (instructionType === 'writeSingleHoldingRegister' || instructionType === 'writeMultipleHoldingRegisters') {
          if (dataType === 'ASCII') return false;
          if (dataType === 'Float32' || dataType === 'Float64') return true;
        }
        return false;
      };

      const signedValue = getSignedDefaultValue();
      form.setFieldValue('isSigned', signedValue);
    }
  }, [dataType, instructionType, form]);

  useEffect(() => {
    if (visible) {
      if (initialValues) {
        form.setFieldsValue(initialValues);
      } else {
        // 新增时重置表单，不设置任何默认值
        form.resetFields();
      }
      setTestResults("");
    }
  }, [visible, initialValues, form]);

  // 判断是否为TCP链路类型
  const isTcpLinkType = linkType === 'tcp';

  // 判断是否为读取指令
  const isReadInstruction = readInstructionTypes.includes(instructionType);

  // 判断是否为写入指令
  const isWriteInstruction = writeInstructionTypes.includes(instructionType);

  // 判断是否为线圈指令（不需要数据类型）
  const isCoilInstruction = coilInstructionTypes.includes(instructionType);

  // 判断是否为寄存器指令（需要寄存器数目）
  const isRegisterInstruction = registerInstructionTypes.includes(instructionType);

  // 判断数据类型是否可选
  const isDataTypeDisabled = isCoilInstruction;

  // 判断有符号是否可选
  const isSignedDisabled = () => {
    if (!instructionType || !dataType) return true;
    if (instructionType === 'writeSingleHoldingRegister' || instructionType === 'writeMultipleHoldingRegisters') {
      return dataType === 'ASCII' || dataType === 'Float32' || dataType === 'Float64';
    }
    return false;
  };

  // 测试功能
  const handleTest = async () => {
    setIsTesting(true);
    try {
      await form.validateFields();

      // 模拟测试过程
      await new Promise(resolve => setTimeout(resolve, 2000));

      const now = new Date();
      const timeStr = now.toLocaleString();

      if (isWriteInstruction) {
        setTestResults(`[${timeStr}] 写入测试成功\n数据已成功写入到从设备`);
      } else {
        setTestResults(`[${timeStr}] 读取测试成功\n成功从从设备读取数据`);
      }
    } catch (error) {
      console.error("测试失败:", error);
      const now = new Date();
      const timeStr = now.toLocaleString();

      if (isWriteInstruction) {
        setTestResults(`[${timeStr}] 写入测试失败\n可能原因：\n1. 连接失败\n2. 寄存器地址未授权\n3. 寄存器值未授权\n4. 从设备故障`);
      } else {
        setTestResults(`[${timeStr}] 读取测试失败\n可能原因：\n1. 连接失败\n2. 寄存器地址未授权\n3. 寄存器数目未授权\n4. 从设备故障`);
      }
    } finally {
      setIsTesting(false);
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
      title={initialValues ? "编辑通道" : "新增通道"}
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
          {/* 通道名称 */}
          <Form.Item
            label="通道名称"
            name="channelName"
            rules={[{ required: true, message: "请输入通道名称" }]}
          >
            <Input placeholder="请输入通道名称" />
          </Form.Item>

          {/* 链路类型 */}
          <Form.Item
            label="链路类型"
            name="linkType"
            rules={[{ required: true, message: "请选择链路类型" }]}
          // extra={
          //   <div>
          //     <div>串口链路类型：使用Modbus RTU，通常用于通过RS-485或RS-232物理接口进行串口通信。</div>
          //     <div>TCP链路类型：使用Modbus TCP/IP，通过TCP/IP和以太网传输Modbus RTU消息。</div>
          //     <div style={{ color: '#666' }}>$RSXXX根据串口设置动态显示为RS485或RS232。如果串口的连接模式未配置为Modbus Client，则不会出现在选项中。</div>
          //   </div>
          // }
          >
            <Select options={linkTypeOptions} />
          </Form.Item>

          {/* Server ID */}
          <Form.Item
            label="Server ID"
            name="serverId"
            rules={[{ required: true, message: "请输入Server ID" }]}
          >
            <Input placeholder="请输入Server ID" />
          </Form.Item>

          {/* IP地址 - 仅TCP时显示 */}
          {isTcpLinkType && (
            <Form.Item
              label="IP地址"
              name="ipAddress"
              rules={[{ required: true, message: "请输入IP地址" }]}
            >
              <Input placeholder="请输入IP地址" />
            </Form.Item>
          )}

          {/* 端口 - 仅TCP时显示 */}
          {isTcpLinkType && (
            <Form.Item
              label="端口"
              name="port"
              rules={[{ required: true, message: "请输入端口" }]}
            >
              <Input placeholder="请输入端口" />
            </Form.Item>
          )}

          {/* 指令类型 */}
          <Form.Item
            label="指令类型"
            name="instructionType"
            rules={[{ required: true, message: "请选择指令类型" }]}
          // extra={
          //   <div>
          //     <div><strong>写命令：</strong>描述如何形成写请求（结合指令类型、链路类型、从地址、数据类型、寄存器地址和寄存器值）以及从设备如何修改数据。</div>
          //     <div><strong>读命令：</strong>描述如何形成读请求（结合指令类型、链路类型、从地址、数据类型、寄存器地址和寄存器数目）以及路由器如何从给定地址开始读取指定数目的值。</div>
          //     <div><strong>Modbus功能码：</strong>读线圈→1，读离散输入→2，读保持寄存器→3，读输入寄存器→4，写单个线圈→5，写单个保持寄存器→6，写多个线圈→15，写多个保持寄存器→16。</div>
          //   </div>
          // }
          >
            <Select options={instructionTypeOptions} />
          </Form.Item>

          {/* 数据类型 */}
          <Form.Item
            label="数据类型"
            name="dataType"
            rules={[{ required: !isDataTypeDisabled, message: "请选择数据类型" }]}
          >
            <Select
              options={dataTypeOptions.map(option => ({
                ...option,
                label: option.isNew ? (
                  <span>
                    <span style={{ color: 'red' }}>●</span> {option.label}
                  </span>
                ) : option.label
              }))}
              disabled={isDataTypeDisabled}
            />
          </Form.Item>

          {/* 字节顺序 */}
          {!isDataTypeDisabled && (
            <Form.Item
              label="字节顺序"
              name="byteOrder"
              rules={[{ required: true, message: "请选择字节顺序" }]}
            // extra="请参考背景部分了解详情。"
            >
              <Select options={byteOrderOptions[dataType as keyof typeof byteOrderOptions] || []} />
            </Form.Item>
          )}

          {/* 寄存器地址 */}
          <Form.Item
            label="寄存器地址"
            name="registerAddress"
            rules={[{ required: true, message: "请输入寄存器地址" }]}
          >
            <Input placeholder="请输入寄存器地址" />
          </Form.Item>

          {/* 寄存器值 - 仅写入指令时显示 */}
          {isWriteInstruction && (
            <Form.Item
              label="寄存器值"
              name="registerValue"
              rules={[{ required: true, message: "请输入寄存器值" }]}
            >
              <Input placeholder="多个值可用空格分隔" />
            </Form.Item>
          )}

          {/* 寄存器数目 - 仅读取指令或寄存器指令时显示 */}
          {isReadInstruction && isRegisterInstruction && (
            <Form.Item
              label="寄存器数目"
              name="registerCount"
              rules={[{ required: true, message: "请输入寄存器数目" }]}
            >
              <Input placeholder="请输入寄存器数目" />
            </Form.Item>
          )}

          {/* 有符号 */}
          <Form.Item
            label="有符号"
            name="isSigned"
            valuePropName="checked"
          // extra={
          //   <div>
          //     <div>如果启用，表示通道的寄存器数据是有符号的；否则为无符号。</div>
          //     <div>这是一个单独的配置项，用于提高可读性，因为将所有有符号/无符号选项打开会使页面混乱。</div>
          //     <div style={{ color: '#666' }}>当指令类型为[写单个保持寄存器]或[写多个保持寄存器]时：如果数据类型为[ASCII]，则未选中且变灰；如果数据类型为[Float]，则选中且变灰。</div>
          //   </div>
          // }
          >
            <Checkbox disabled={isSignedDisabled()}>有符号</Checkbox>
          </Form.Item>

          {/* 小数位数 - 仅读取指令且为INT或Float时显示 */}
          {isReadInstruction && (dataType === 'INT16' || dataType === 'INT32' || dataType === 'INT64' || dataType === 'Float32' || dataType === 'Float64') && (
            <Form.Item
              label="小数位数"
              name="decimalPlaces"
            // extra="表示从远程通道读取的值中小数点的位置。例如，如果读取的值为1234且小数位数为2，则实际值为12.34。"
            >
              <InputNumber
                min={0}
                max={9}
                style={{ width: '100%' }}
                placeholder="请输入小数位数"
              />
            </Form.Item>
          )}

          <Divider />

          {/* 测试功能 */}
          <Form.Item label="测试">
            <Space direction="vertical" style={{ width: '100%' }}>
              <Button
                icon={<PlayCircleOutlined />}
                onClick={handleTest}
                loading={isTesting}
                style={{ width: '100%' }}
              >
                测试
              </Button>
              {testResults && (
                <TextArea
                  value={testResults}
                  readOnly
                  rows={6}
                  placeholder="测试结果将显示在这里"
                />
              )}
            </Space>
          </Form.Item>
        </Form>
      </div>
    </Modal>
  );
};

export default ChannelModal;
