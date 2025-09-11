// --- 配置区 ---
export const MOCK_SERVER_PORT: number = 3001;

// export const REAL_DEVICE_IP: string = 'http://192.168.43.118';  // UG65
export const REAL_DEVICE_IP: string = 'http://192.168.43.44'; //UR32 
// export const REAL_DEVICE_IP: string = 'http://192.168.43.43'; //UR35 
// export const REAL_DEVICE_IP: string = 'http://192.168.43.33'; //EG71 
// export const REAL_DEVICE_IP: string = 'http://192.168.43.34'; //EG71 


// export const REAL_DEVICE_IP: string = 'http://192.168.44.95'; // 3x ZW
// export const REAL_DEVICE_IP: string = 'http://192.168.40.117'; // 3x YZ
// export const REAL_DEVICE_IP: string = 'http://192.168.40.68'; // 3x MX
// export const REAL_DEVICE_IP: string = 'http://192.168.40.157'; // 3x XL

// export const REAL_DEVICE_IP: string = 'http://192.168.40.116'; // 6x


// 新增一个配置开关
// 设置为 true: 所有 /cgi 请求都返回同一个固定响应
// 设置为 对象: 直接返回这个数据
export const MOCK_CGI_DATA = false
// export const MOCK_CGI_DATA = {
//   success: true,
//   message: "Universal mock response for all CGI requests (from config toggle).",
//   data: { status: "ok" }
// }; 