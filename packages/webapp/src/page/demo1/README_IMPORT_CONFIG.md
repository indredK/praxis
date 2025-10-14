# 导入功能配置说明

## 校验模式切换

导入功能的校验模式现在通过代码内部控制，不再向用户显示开关。

### 如何切换校验模式

1. **前端校验模式**（默认）：
   - 打开 `importConfig.ts` 文件
   - 设置 `USE_FRONTEND_VALIDATION: true`
   - 校验在客户端进行，速度快，适合开发环境

2. **后端校验模式**：
   - 打开 `importConfig.ts` 文件
   - 设置 `USE_FRONTEND_VALIDATION: false`
   - 校验在服务器端进行，更安全，适合生产环境

### 配置文件说明

```typescript
export const IMPORT_CONFIG = {
    // 校验模式控制
    USE_FRONTEND_VALIDATION: true,  // 切换校验模式的地方
    
    // 最大通道数量限制
    MAX_CHANNEL_COUNT: 1024,
    
    // 支持的文件格式
    SUPPORTED_FILE_TYPES: ['.csv', '.xlsx', '.xls'],
    
    // 校验超时时间（毫秒）
    VALIDATION_TIMEOUT: 5000,
    
    // 是否显示详细的校验信息
    SHOW_DETAILED_VALIDATION_INFO: true,
};
```

### 后端API配置

当使用后端校验时，可以在 `BACKEND_API_CONFIG` 中配置API端点：

```typescript
export const BACKEND_API_CONFIG = {
    // 校验API端点
    VALIDATION_ENDPOINT: '/api/validate-channels',
    
    // 请求超时时间
    REQUEST_TIMEOUT: 10000,
    
    // 重试次数
    MAX_RETRIES: 3,
};
```

### 注意事项

- 修改配置后需要重新编译应用
- 后端校验需要实现相应的API接口
- 前端校验和后端校验的错误信息格式保持一致
