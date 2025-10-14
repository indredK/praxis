// 导入功能配置
export const IMPORT_CONFIG = {
    // 校验模式控制
    // true: 使用前端校验（快速验证数据格式）
    // false: 使用后端校验（调用服务器API进行验证）
    USE_FRONTEND_VALIDATION: true,
    
    // 最大通道数量限制
    MAX_CHANNEL_COUNT: 1024,
    
    // 支持的文件格式
    SUPPORTED_FILE_TYPES: ['.csv', '.xlsx', '.xls'],
    
    // 校验超时时间（毫秒）
    VALIDATION_TIMEOUT: 5000,
    
    // 是否显示详细的校验信息
    SHOW_DETAILED_VALIDATION_INFO: true,
};

// 后端API配置（当使用后端校验时）
export const BACKEND_API_CONFIG = {
    // 校验API端点
    VALIDATION_ENDPOINT: '/api/validate-channels',
    
    // 请求超时时间
    REQUEST_TIMEOUT: 10000,
    
    // 重试次数
    MAX_RETRIES: 3,
};
