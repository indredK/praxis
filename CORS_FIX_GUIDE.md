# 🔧 CORS修复指南

## ✅ 已完成的修改

### 后端CORS配置 (`packages/backend/src/main.ts`)
```typescript
app.enableCors({
  origin: true, // 开发环境允许所有origin
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  exposedHeaders: ['Content-Length', 'Content-Type'],
  maxAge: 3600,
});
```

### 前端API配置 (`packages/flutter/flutter_application_1/lib/config/api_config.dart`)
- 后端地址: `http://localhost:3001/api/v1`
- 筛选配置端点: `/filters/config`

## 🧪 测试步骤

### 1. 重启后端
```bash
cd /Users/kindred/Desktop/web/praxis

# 杀掉旧进程
lsof -ti:3001 | xargs kill -9

# 重新构建并启动
cd packages/backend && pnpm build && cd ../..
pnpm dev:backend
```

### 2. 验证后端API
```bash
# 测试基本API
curl 'http://localhost:3001/api/v1/health'

# 测试筛选配置
curl 'http://localhost:3001/api/v1/filters/config' | jq '.filterTree.title'

# 测试CORS（模拟浏览器请求）
curl -H "Origin: http://localhost:8080" 'http://localhost:3001/api/v1/filters/config' | jq '.filterTree.title'
```

### 3. Flutter Web热重载
在Flutter应用中：
1. 进入"设置"页面
2. 点击"🧪 API测试"
3. 页面会自动请求后端筛选配置
4. 查看浏览器控制台（F12）的Network标签查看CORS响应头

## 🔍 调试技巧

### 查看CORS响应头
```bash
curl -v -H "Origin: http://localhost:8080" 'http://localhost:3001/api/v1/filters/config' 2>&1 | grep "Access-Control"
```

应该看到：
```
< Access-Control-Allow-Origin: http://localhost:8080
< Access-Control-Allow-Credentials: true
< Access-Control-Expose-Headers: Content-Length,Content-Type
```

### 浏览器控制台
打开浏览器开发者工具（F12）:
1. **Network标签**: 查看请求/响应头
2. **Console标签**: 查看CORS错误信息
3. 如果看到"has been blocked by CORS policy"，说明后端CORS配置未生效

## 🎯 预期结果

### 成功的响应
- HTTP状态码: 200
- 包含 `Access-Control-Allow-Origin` 头
- JSON数据包含 `filterTree` 和 `comparisonModes`

### API测试页面显示
```
✅ 后端对接成功
成功从后端 API 获取筛选配置

筛选树配置
根节点: 产品筛选
子节点数量: 7
```

## ⚡ 快速修复脚本

如果还是有问题，运行：
```bash
# 完全重启
cd /Users/kindred/Desktop/web/praxis
lsof -ti:3001 | xargs kill -9 2>/dev/null
cd packages/backend && pnpm build
cd ../.. && pnpm dev:backend

# 等待10秒后测试
sleep 10
curl 'http://localhost:3001/api/v1/filters/config' | jq '.'
```

## 📝 注意事项

1. **开发环境**: 当前CORS配置为`origin: true`（允许所有源），仅用于开发
2. **生产环境**: 需要修改为具体的域名列表
3. **Flutter热重载**: 修改后端代码后，Flutter需要重新发起请求才能看到效果

