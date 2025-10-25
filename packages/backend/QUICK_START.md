# 🚀 快速启动指南

## 1. 启动开发服务器

```bash
# 在 monorepo 根目录
pnpm dev:backend
```

服务器将在 `http://localhost:3001` 启动。

## 2. 测试 API

### 健康检查

```bash
curl http://localhost:3001/api/v1/health
```

### 创建用户

```bash
curl -X POST http://localhost:3001/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "测试用户",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 获取产品列表

```bash
curl http://localhost:3001/api/v1/products
```

## 3. 查看日志

启动服务器后，你会看到：

```
✅ --- Bootstrap --- ✅
🚀 Application is running on: http://localhost:3001/api/v1
📝 Environment: development
```

每个请求都会自动记录：

```
📥 GET /api/v1/health - Mozilla/5.0...
📤 GET /api/v1/health - 15ms - Success
```

## 4. 运行测试

```bash
# 在 backend 目录
cd packages/backend

# 运行所有测试
pnpm test

# 监听模式
pnpm test:watch
```

## 5. 项目结构一览

```
src/
├── config/          # 环境配置
├── common/          # 共享模块（过滤器、拦截器等）
├── health/          # 健康检查
├── users/           # 用户 CRUD 示例
├── products/        # 产品模块（带分页）
├── app.module.ts    # 根模块
└── main.ts          # 入口文件
```

## 6. 常用命令

```bash
# 开发
pnpm dev              # 启动开发服务器（热重载）

# 构建
pnpm build            # 编译 TypeScript

# 测试
pnpm test             # 运行测试
pnpm test:watch       # 测试监听模式
pnpm test:cov         # 生成覆盖率报告

# 代码质量
pnpm lint             # 运行 ESLint
pnpm format           # 格式化代码
pnpm typecheck        # 类型检查

# 生产
pnpm start:prod       # 运行生产构建
```

## 7. 生成新模块

```bash
cd packages/backend

# 生成完整模块（module + controller + service）
nest g resource feature-name

# 或者单独生成
nest g module feature-name
nest g controller feature-name
nest g service feature-name
```

## 8. 配置环境变量

编辑 `packages/backend/.env`：

```env
NODE_ENV=development
PORT=3001
LOG_LEVEL=debug
CORS_ORIGIN=http://localhost:5173,http://localhost:3000
```

## 9. 下一步

- 📖 阅读 [README.md](./README.md) 了解完整功能
- 📝 查看 [API_EXAMPLES.md](./API_EXAMPLES.md) 学习所有 API 端点
- 🔨 开始构建你的功能模块！

## 🎉 完成！

你现在有了一个企业级的 NestJS 后端服务，包含：

- ✅ 完整的类型安全
- ✅ 自动验证
- ✅ 全局错误处理
- ✅ 请求日志
- ✅ CORS 支持
- ✅ 健康检查
- ✅ 测试配置
- ✅ 示例 CRUD 模块

开始编码吧！🚀

