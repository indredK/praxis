// --- 配置区 ---
export const MOCK_SERVER_PORT: number = 3001;
export const REAL_DEVICE_IP: string = 'http://192.168.40.69'; // 请确保这是您当前设备的正确 IP
// 新增一个配置开关
// 设置为 true: 所有 /cgi 请求都返回同一个固定响应
// 设置为 对象: 直接返回这个数据
export const MOCK_CGI_DATA = false
// export const MOCK_CGI_DATA = {
//   success: true,
//   message: "Universal mock response for all CGI requests (from config toggle).",
//   data: { status: "ok" }
// }; 