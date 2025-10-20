export interface AlarmData {
  id: string;
  readChannelName: string;
  condition: string;
  minThreshold: number;
  alarmMethod: string[];
  phoneGroup: string;
  emailGroup: string;
  normalAlarmContent: string;
  abnormalAlarmContent: string;
  continuousAlarm: boolean;
  writeChannelName?: string;
}

export const mockAlarmData: AlarmData[] = [
  {
    id: '1',
    readChannelName: '通道1',
    condition: '小于(<)',
    minThreshold: 0,
    alarmMethod: ['短信'],
    phoneGroup: '技术组',
    emailGroup: '运维组',
    normalAlarmContent: '提示:$YEAR/$MON/$DAY $TIME,从通道$NAME的地址$ADDRESS 读取到正常数据$VALUE。(异常范围是$CONDITION)',
    abnormalAlarmContent: '提示:$YEAR/$MON/$DAY $TIME,从通道$NAME的地址$ADDRESS 读取到异常数据$VALUE。(异常范围是$CONDITION)',
    continuousAlarm: false,
    writeChannelName: '通道1',
  },
  {
    id: '2',
    readChannelName: '通道2',
    condition: '大于(>)',
    minThreshold: 0,
    alarmMethod: ['邮箱'],
    phoneGroup: '管理组',
    emailGroup: '监控组',
    normalAlarmContent: '提示:$YEAR/$MON/$DAY $TIME,从通道$NAME的地址$ADDRESS 读取到正常数据$VALUE。(异常范围是$CONDITION)',
    abnormalAlarmContent: '提示:$YEAR/$MON/$DAY $TIME,从通道$NAME的地址$ADDRESS 读取到异常数据$VALUE。(异常范围是$CONDITION)',
    continuousAlarm: true,
  },
  {
    id: '3',
    readChannelName: '通道3',
    condition: '等于(=)',
    minThreshold: 50,
    alarmMethod: ['短信', '邮箱'],
    phoneGroup: '值班组',
    emailGroup: '技术组',
    normalAlarmContent: '提示:$YEAR/$MON/$DAY $TIME,从通道$NAME的地址$ADDRESS 读取到正常数据$VALUE。(异常范围是$CONDITION)',
    abnormalAlarmContent: '提示:$YEAR/$MON/$DAY $TIME,从通道$NAME的地址$ADDRESS 读取到异常数据$VALUE。(异常范围是$CONDITION)',
    continuousAlarm: false,
    writeChannelName: '通道4',
  },
];

// 条件选项
export const conditionOptions = [
  { label: '小于(<)', value: '小于(<)' },
  { label: '大于(>)', value: '大于(>)' },
  { label: '等于(=)', value: '等于(=)' },
  { label: '不等于(!=)', value: '不等于(!=)' },
  { label: '小于等于(<=)', value: '小于等于(<=)' },
  { label: '大于等于(>=)', value: '大于等于(>=)' },
];

// 告警方式选项
export const alarmMethodOptions = [
  { label: '短信', value: '短信' },
  { label: '邮箱', value: '邮箱' },
];

// 通道名称选项（从demo1获取）
export const channelNameOptions = [
  { label: '通道1', value: '通道1' },
  { label: '通道2', value: '通道2' },
  { label: '通道3', value: '通道3' },
  { label: '通道4', value: '通道4' },
  { label: '通道5', value: '通道5' },
  { label: '通道6', value: '通道6' },
  { label: '通道7', value: '通道7' },
  { label: '通道8', value: '通道8' },
  { label: '通道9', value: '通道9' },
  { label: '通道10', value: '通道10' },
];
