import { MockRule } from "../../type.js";


export interface AlarmSetting {
    id: string;
    alarm_name: string;                    // 告警名称
    index: string;                         // 索引
    cmd_tmp: number;                       // 指令模板
    sign_tmp: string;                      // 符号模板
    condition: number;                     // 条件
    limit_min: string;                     // 最小限制值
    limit_max: string;                     // 最大限制值
    alarm_action: string;                  // 告警动作
    normal_content: string;                // 正常内容模板
    abnormal_content: string;              // 异常内容模板
    phone: string;                         // 电话号码
    email: string;                         // 邮箱地址
    alarm: number;                         // 告警状态
    action: number;                        // 动作类型
    level_condition: string;               // 级别条件
}

// 系统级参数
export const alarmLimits = {
    maxAlarms: 1024,                       // 最大告警数
};

export type AlarmSettingList = AlarmSetting[];


export function generateRandomAlarmSettings(count: number): AlarmSettingList {
    const conditionTypes = [1, 2, 3, 4]; // 条件类型：1=大于, 2=小于, 3=等于, 4=不等于
    const signTypes = ['true', 'false'];
    const actionTypes = [1, 2, 3]; // 动作类型
    const alarmStatuses = [0, 1]; // 0=正常, 1=告警
    
    const random = <T>(arr: readonly T[]): T => arr[Math.floor(Math.random() * arr.length)];
    const randomInt = (min: number, max: number): number => Math.floor(Math.random() * (max - min + 1)) + min;
    const randomId = (): string => {
        const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < 10; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    };
    
    // 生成随机电话号码
    const randomPhone = (): string => {
        const prefix = ['138', '139', '186', '188', '189'];
        return random(prefix) + String(randomInt(10000000, 99999999));
    };
    
    // 生成随机邮箱
    const randomEmail = (): string => {
        const domains = ['example.com', 'test.com', 'mail.com'];
        const username = `user${randomInt(100, 999)}`;
        return `${username}@${random(domains)}`;
    };

    return Array.from({ length: count }, (_, idx) => {
        const id = randomId();
        const condition = random(conditionTypes);
        const limitMin = String(randomInt(0, 100));
        const limitMax = String(randomInt(101, 200));
        const cmdTmp = randomInt(1, 10);
        const alarmAction = String(randomInt(1, 20));
        
        // 条件文本映射
        const conditionText: Record<number, string> = {
            1: `> ${limitMin}`,
            2: `< ${limitMax}`,
            3: `= ${limitMin}`,
            4: `!= ${limitMin}`,
        };

        return {
            id,
            alarm_name: `Alarm_${String(idx + 1).padStart(3, '0')}`,
            index: id,
            cmd_tmp: cmdTmp,
            sign_tmp: random(signTypes),
            condition,
            limit_min: limitMin,
            limit_max: limitMax,
            alarm_action: alarmAction,
            normal_content: `提示: $YEAR/$MON/$DAY $TIME，从通道$NAME的地址$ADDRESS 读取到正常数据$VALUE。(异常范围是${conditionText[condition]})`,
            abnormal_content: `提示: $YEAR/$MON/$DAY $TIME，从通道$NAME的地址$ADDRESS 读取到异常数据$VALUE。(异常范围是${conditionText[condition]})`,
            phone: randomPhone(),
            email: randomEmail(),
            alarm: random(alarmStatuses),
            action: random(actionTypes),
            level_condition: `(${randomInt(1, 3)},${randomInt(1, 3)})`,
        };
    });
}

// 使用示例
export const randomAlarms = generateRandomAlarmSettings(21);


// 生成更多数据用于翻页测试
export const allAlarms = generateRandomAlarmSettings(100); // 生成100个告警设置用于翻页

export const mockData: MockRule[] = [
    {
        requestMatch: {
            id: 47,
            execute: 1,
            core: "yruo_modbus_alarmsettings",
            function: "get",
            values: [
                { base: "yruo_modbus_alarmsettings" }
            ],
        },
        // 使用合并后的modifier功能支持翻页
        modifier: (realDeviceResponse, req, payload) => {
            // 新模式：直接生成mock数据（realDeviceResponse为null）
            if (realDeviceResponse === null) {
                // 从请求体中提取翻页参数
                const values = payload.values?.[0];
                const limit = values?.limit || 10;
                const start = values?.start || 0;
                const page = Math.floor(start / limit) + 1;

                console.log(`[AlarmSettings] 动态生成数据: limit=${limit}, start=${start}, page=${page}`);

                // 计算分页数据
                const endIndex = start + limit;
                const paginatedAlarms = allAlarms.slice(start, endIndex);

                console.log(`[AlarmSettings] 返回数据: ${paginatedAlarms.length}条 (start=${start}, limit=${limit})`);

                // 返回正确的响应格式
                return {
                    "get": [
                        {
                            "type": "yruo_modbus_alarmsettings",
                            "index": 1,
                            "value": {
                                "total": allAlarms.length,
                                "alarmsettings": paginatedAlarms
                            }
                        }
                    ]
                };
            }

            // 旧模式：修改真实设备响应（保持向后兼容）
            // 这里可以添加修改真实设备响应的逻辑
            return realDeviceResponse;
        },
    },
]
console.log('[ mockData ] >', mockData)