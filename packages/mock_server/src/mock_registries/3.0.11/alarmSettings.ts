import { MockRule } from "../../type.js";
export const mockData: MockRule[] = [
    {
        requestMatch: {
            core: "yruo_firewall_iorules",
            function: "get",
            values: [
                { base: "yruo_firewall_iorules" }, // 与规则1的 values 不同
            ],
        },
        responseData: {
            "id": 5,
            "model": "UR35",
            "pn": "L04EU2211111CN0010000000",
            "oem": "0000",
            "rtver": "35.3.0.10-r1",
            "status": 0,
            "result": [
                {
                    "get": [
                        {
                            "type": "yruo_firewall_policy",
                            "index": 1,
                            "value": {
                                "inbound_policy": 1,
                                "outbound_policy": 2,
                                "list": [
                                    "ALL",
                                    "WAN"
                                ]
                            }
                        },
                        {
                            "type": "yruo_firewall_inbound_list",
                            "index": 1,
                            "value": {
                                "priority": 1,
                                "interface": "ALL",
                                "source_ip": "192.168.50.50",
                                "source_port": 29,
                                "action": 2,
                                "protocol": "UDP",
                                "device_port": 99,

                            }
                        },
                        {
                            "type": "yruo_firewall_outbound_list",
                            "index": 1,
                            "value": {
                                "priority": 1,
                                "interface": "ALL",
                                "target_ip": "192.168.50.50",
                                "target_port": 22,
                                "action": 2,
                                "protocol": "UDP",
                            }
                        },
                        {
                            "type": "yruo_firewall_outbound_list",
                            "index": 2,
                            "value": {
                                "priority": 2,
                                "interface": "ALL",
                                "target_ip": "192.168.50.51",
                                "target_port": 33,
                                "action": 2,
                                "protocol": "UDP",
                            }
                        }
                    ]
                }
            ]
        },
    },
]