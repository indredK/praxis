# 🔌 前后端对接状态

## ✅ 已完成

### 1. 后端API (NestJS)
- ✅ 筛选配置端点: `GET /api/v1/filters/config`  
- ✅ 产品列表端点: `GET /api/v1/products`
- ✅ 数据库: PostgreSQL + Prisma (33个产品已填充)
- ✅ CORS配置: 已配置允许所有来源（开发环境）

### 2. 前端集成 (Flutter Web)
- ✅ HTTP客户端: `lib/core/services/http_client.dart`
- ✅ API配置: `lib/config/api_config.dart`
- ✅ 服务更新: `FilterApiService` 支持真实后端
- ✅ 测试页面: "设置 → 🧪 API测试"
- ✅ 错误处理: Fallback到Mock数据

## ⚠️ 当前问题

### CORS错误 (浏览器控制台)
```
ClientException: Failed to fetch
```

**原因**: Flutter Web在浏览器中受到CORS安全限制

## 🔧 解决方案

### 方案1: 重启后端（推荐）
```bash
# 在终端执行
cd /Users/kindred/Desktop/web/praxis
lsof -ti:3001 | xargs kill -9
pnpm dev:backend
```

等待后端启动后（看到"🚀 Application is running"），在Flutter Web点击"刷新"按钮。

### 方案2: 检查后端是否运行
```bash
curl 'http://localhost:3001/api/v1/health'
```

应该返回:
```json
{"status":"ok","timestamp":"..."}
```

### 方案3: 验证CORS
```bash
curl -H "Origin: http://localhost:8080" 'http://localhost:3001/api/v1/filters/config' | jq '.filterTree.title'
```

应该返回:
```
产品筛选
```

## 📱 测试步骤

1. **确保后端运行**:
   ```bash
   curl 'http://localhost:3001/api/v1/health'
   ```

2. **在Flutter Web中测试**:
   - 打开应用: http://localhost:8080
   - 进入"设置"标签
   - 点击"🧪 API测试"
   - 查看是否显示"✅ 后端对接成功"

3. **如果失败，查看浏览器控制台** (F12):
   - Network标签: 查看请求状态
   - Console标签: 查看错误信息

## 🎯 预期结果（成功时）

### API测试页面
```
✅ 后端对接成功
成功从后端 API 获取筛选配置

筛选树配置
根节点: 产品筛选
子节点数量: 7个筛选器

对比模式
- 价格对比 (3个筛选器)
- 自家对比 (4个筛选器)  
- 同类对比 (5个筛选器)
```

### 控制台日志
```
📡 正在请求后端API: http://localhost:3001/api/v1/filters/config
✅ 后端响应成功
```

## 🐛 常见问题

### Q: 显示"⚠️ 后端请求失败，使用Mock数据"
**A**: 这是正常的Fallback机制。原因可能是:
1. 后端未启动
2. CORS未正确配置
3. 网络请求被浏览器阻止

**解决**: 按照"方案1"重启后端

### Q: CORS错误如何调试？
**A**: 
1. 打开浏览器开发者工具 (F12)
2. Network标签 → 找到失败的请求
3. 查看Response Headers，应该包含:
   - `Access-Control-Allow-Origin: http://localhost:8080`
   - `Access-Control-Allow-Credentials: true`

### Q: 数据从哪里来？
**A**: 
- **开发阶段**: 可在 `api_config.dart` 设置 `useMockData = true` 使用本地Mock数据
- **对接后端**: 设置 `useMockData = false`，从 `http://localhost:3001` 获取真实数据

## 📚 相关文件

- 后端CORS配置: `packages/backend/src/main.ts`
- 前端API配置: `lib/config/api_config.dart`
- HTTP客户端: `lib/core/services/http_client.dart`
- 筛选服务: `lib/features/product/data/services/filter_api_service.dart`
- API测试页面: `lib/features/product/presentation/pages/api_test_page.dart`

## 🚀 下一步

1. ✅ 筛选配置对接 ← **当前阶段**
2. ⏭️ 产品数据对接
3. ⏭️ 筛选功能实现
4. ⏭️ 产品对比页面对接

