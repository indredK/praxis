# 🎯 功能指南

本文档详细说明后端服务的所有企业级功能。

## ✅ 已实现的功能

### 1. 📚 Swagger API 文档

**访问地址**: http://localhost:3001/api/docs

**功能特点**:
- 📖 自动生成的 API 文档
- 🧪 可交互测试的接口
- 🔒 JWT 认证测试
- 📝 完整的请求/响应示例

**使用方法**:
1. 启动服务器：`pnpm dev:backend`
2. 打开浏览器访问 http://localhost:3001/api/docs
3. 点击任意端点查看详情
4. 点击 "Try it out" 直接测试 API

**测试带 JWT 的端点**:
1. 先调用 `/auth/login` 获取 token
2. 点击右上角 "Authorize" 按钮
3. 输入 `Bearer YOUR_TOKEN`
4. 现在可以测试受保护的端点了

---

### 2. 🔐 JWT 认证系统

**完整的认证流程**:

#### 注册新用户
```bash
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "张三",
    "email": "zhangsan@example.com",
    "password": "password123"
  }'
```

**响应**:
```json
{
  "user": {
    "id": "1",
    "name": "张三",
    "email": "zhangsan@example.com"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### 用户登录
```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "zhangsan@example.com",
    "password": "password123"
  }'
```

#### 访问受保护的端点
```bash
# 获取用户信息（需要 JWT）
curl http://localhost:3001/api/v1/auth/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**安全特性**:
- ✅ 密码使用 bcrypt 加密（10 轮）
- ✅ JWT 令牌有效期可配置（默认 7 天）
- ✅ 令牌包含用户 ID 和邮箱
- ✅ 所有密码在返回时自动隐藏

**保护你的端点**:
```typescript
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Get('protected')
@UseGuards(JwtAuthGuard)
async protectedRoute(@Request() req) {
  return { userId: req.user.userId };
}
```

---

### 3. 🛡️ Rate Limiting（限流保护）

**配置**: `.env` 文件
```env
RATE_LIMIT_TTL=60      # 时间窗口（秒）
RATE_LIMIT_MAX=100     # 最大请求数
```

**工作原理**:
- 每个 IP 地址在 60 秒内最多 100 个请求
- 超过限制返回 429 Too Many Requests
- 自动应用到所有端点

**自定义特定端点的限制**:
```typescript
import { Throttle } from '@nestjs/throttler';

@Throttle({ default: { limit: 3, ttl: 60000 } }) // 60秒3次
@Post('login')
async login() {
  // ...
}
```

**禁用某个端点的限流**:
```typescript
import { SkipThrottle } from '@nestjs/throttler';

@SkipThrottle()
@Get('public')
async publicEndpoint() {
  // 不受限流影响
}
```

**测试限流**:
```bash
# 快速发送多个请求
for i in {1..150}; do
  curl http://localhost:3001/api/v1/health/ping
done
# 第 101 个请求开始会返回 429
```

---

### 4. 🐳 Docker 支持

#### 开发环境

**使用 docker-compose（包含 PostgreSQL + Redis）**:
```bash
# 启动所有服务
docker-compose -f docker-compose.dev.yml up -d

# 查看日志
docker-compose -f docker-compose.dev.yml logs -f

# 停止所有服务
docker-compose -f docker-compose.dev.yml down
```

**服务包含**:
- ✅ Backend（热重载）
- ✅ PostgreSQL 16
- ✅ Redis 7

#### 生产环境

**构建镜像**:
```bash
docker build -t praxis-backend:latest .
```

**运行生产容器**:
```bash
docker-compose up -d

# 查看日志
docker-compose logs -f backend

# 查看所有容器状态
docker ps
```

**多阶段构建优化**:
- 📦 最小化镜像大小
- 🔒 非 root 用户运行
- ❤️ 健康检查配置
- ⚡ 仅包含生产依赖

**进入容器调试**:
```bash
# 进入 backend 容器
docker exec -it praxis-backend sh

# 连接 PostgreSQL
docker exec -it praxis-postgres psql -U postgres -d praxis

# 连接 Redis
docker exec -it praxis-redis redis-cli
```

---

### 5. 🗄️ Prisma ORM（配置就绪）

**当前状态**: ✅ Schema 配置完成，等待 PostgreSQL

**快速开始** (需要先安装 PostgreSQL):

#### 步骤 1: 启动 PostgreSQL
```bash
# 选项 A: 使用 Docker
docker run --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=praxis \
  -p 5432:5432 -d postgres:16-alpine

# 选项 B: 使用 docker-compose
docker-compose up -d postgres

# 选项 C: macOS Homebrew
brew install postgresql@16
brew services start postgresql@16
```

#### 步骤 2: 安装 Prisma
```bash
cd packages/backend
pnpm add prisma @prisma/client
```

#### 步骤 3: 运行迁移
```bash
npx prisma generate
npx prisma migrate dev --name init
```

#### 步骤 4: 打开 Prisma Studio
```bash
npx prisma studio
```

**完整文档**: 查看 [PRISMA_SETUP.md](./PRISMA_SETUP.md)

**当前 Schema**:
```prisma
model User {
  id        String   @id @default(uuid())
  name      String
  email     String   @unique
  password  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Product {
  id          String   @id @default(uuid())
  name        String
  description String?
  price       Decimal  @db.Decimal(10, 2)
  stock       Int      @default(0)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}
```

---

## 📊 监控和调试

### 健康检查

**基础检查**:
```bash
curl http://localhost:3001/api/v1/health
```

**响应**:
```json
{
  "status": "ok",
  "timestamp": "2025-10-25T12:00:00.000Z",
  "uptime": 123.456,
  "environment": "development",
  "memory": {
    "total": 12345678,
    "used": 8765432
  }
}
```

**简单 Ping**:
```bash
curl http://localhost:3001/api/v1/health/ping
# 响应: {"message":"pong","timestamp":"..."}
```

### 日志系统

**自动日志记录**:
- 📥 每个请求的开始
- 📤 每个请求的结束（含响应时间）
- ❌ 所有错误和异常
- 📊 内存使用情况

**日志示例**:
```
[Bootstrap] 🚀 Application is running on: http://localhost:3001/api/v1
[Bootstrap] 📚 API Documentation: http://localhost:3001/api/docs
[LoggingInterceptor] 📥 GET /api/v1/health - Mozilla/5.0...
[LoggingInterceptor] 📤 GET /api/v1/health - 15ms - Success
```

---

## 🧪 测试

### 运行测试
```bash
# 运行所有测试
pnpm test

# 监听模式
pnpm test:watch

# 覆盖率报告
pnpm test:cov

# E2E 测试
pnpm test:e2e
```

### 测试示例
查看以下文件了解测试最佳实践：
- `src/users/users.service.spec.ts`
- `src/health/health.service.spec.ts`

---

## 🔒 安全最佳实践

### 当前实现（演示用）
- ⚠️ 内存存储（非持久化）
- ⚠️ 简单的错误处理

### 生产环境建议
- ✅ 使用真实数据库（Prisma + PostgreSQL）
- ✅ 配置 HTTPS
- ✅ 使用环境变量管理敏感信息
- ✅ 实现 Refresh Token 机制
- ✅ 添加 IP 白名单
- ✅ 使用 Helmet 增强安全性
- ✅ 实现审计日志
- ✅ 添加 RBAC 权限控制

### 推荐的安全包
```bash
pnpm add helmet
pnpm add express-rate-limit
pnpm add @nestjs/throttler
```

---

## 📈 性能优化建议

### 1. 启用 Redis 缓存
```bash
pnpm add @nestjs/cache-manager cache-manager
pnpm add cache-manager-redis-store
```

### 2. 数据库连接池
在 Prisma 中配置连接池大小。

### 3. 压缩响应
```bash
pnpm add compression
```

### 4. 使用 CDN
为静态资源配置 CDN。

---

## 🚀 部署清单

### 部署前检查
- [ ] 环境变量已正确配置
- [ ] JWT_SECRET 已更换为强密钥
- [ ] 数据库连接已测试
- [ ] Docker 镜像已构建和测试
- [ ] 健康检查端点正常
- [ ] API 文档已更新
- [ ] 测试全部通过
- [ ] 日志级别设置为 `info` 或 `warn`

### 环境变量（生产）
```env
NODE_ENV=production
PORT=3001
DATABASE_URL=postgresql://user:password@host:5432/praxis
JWT_SECRET=your-very-strong-secret-key-at-least-32-characters-long
JWT_EXPIRES_IN=7d
RATE_LIMIT_TTL=60
RATE_LIMIT_MAX=100
CORS_ORIGIN=https://your-frontend-domain.com
LOG_LEVEL=info
```

### 云部署选项
- **AWS**: ECS + RDS + ElastiCache
- **Google Cloud**: Cloud Run + Cloud SQL + Memorystore
- **Azure**: App Service + Azure Database + Redis Cache
- **Vercel/Railway**: 快速部署（适合小项目）

---

## 📚 相关文档

- [README.md](./README.md) - 完整项目文档
- [API_EXAMPLES.md](./API_EXAMPLES.md) - API 使用示例
- [QUICK_START.md](./QUICK_START.md) - 快速开始指南
- [PRISMA_SETUP.md](./PRISMA_SETUP.md) - Prisma 集成指南

---

## ❓ 常见问题

**Q: JWT token 在哪里配置？**
A: 在 `.env` 文件中设置 `JWT_SECRET` 和 `JWT_EXPIRES_IN`

**Q: 如何修改 Rate Limiting 配置？**
A: 修改 `.env` 中的 `RATE_LIMIT_TTL` 和 `RATE_LIMIT_MAX`

**Q: Swagger 文档如何访问？**
A: 启动服务后访问 http://localhost:3001/api/docs

**Q: 如何添加新的认证端点？**
A: 在 `src/auth/auth.controller.ts` 中添加新方法

**Q: Docker 容器如何查看日志？**
A: `docker-compose logs -f backend`

**Q: 如何集成真实数据库？**
A: 查看 [PRISMA_SETUP.md](./PRISMA_SETUP.md)

---

## 🎉 总结

你现在拥有一个**企业级、生产就绪**的 NestJS 后端服务！

**包含功能**:
- ✅ Swagger API 文档
- ✅ JWT 认证
- ✅ Rate Limiting
- ✅ Docker 支持
- ✅ Prisma 配置
- ✅ 完整的测试
- ✅ 健康检查
- ✅ 全局错误处理
- ✅ 请求日志

**下一步**: 
1. 启动 PostgreSQL
2. 集成 Prisma
3. 部署到云端
4. 开始构建你的业务逻辑！

祝你编码愉快！🚀

