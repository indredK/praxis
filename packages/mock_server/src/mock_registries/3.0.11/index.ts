// 将同级的其他文件导入到这里,然后一起导出
import { mockData as mqttForwardingData } from "./mqttForwarding.js";
import { mockData as tcpForwardingData } from "./tcpForwarding.js";
import { mockData as alarmSettingsData } from "./alarmSettings.js";
import { mockData as channelSettingsData } from "./channelSettings.js";
import { MockRule } from "../../type.js";

export const mockData: MockRule[] = [
    ...mqttForwardingData,
    ...tcpForwardingData,
    ...alarmSettingsData,
    ...channelSettingsData,
];