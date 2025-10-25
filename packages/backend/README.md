# @praxis/backend

企业级 NestJS 后端服务，集成到 Praxis monorepo。

## 🎯 特性

### 核心功能
- ✅ **TypeScript** - 完整的类型安全
- ✅ **依赖注入** - NestJS 强大的 DI 系统
- ✅ **模块化架构** - 按功能组织的清晰结构
- ✅ **配置管理** - 环境变量验证和类型安全配置

### 安全与认证
- ✅ **JWT 认证** - 完整的 JWT + Passport.js 认证系统
- ✅ **密码加密** - 使用 bcrypt 安全存储密码
- ✅ **Rate Limiting** - 防止 API 滥用的限流保护
- ✅ **CORS 支持** - 配置化的跨域资源共享

### 开发体验
- ✅ **Swagger API 文档** - 自动生成的交互式 API 文档
- ✅ **全局错误处理** - 统一的异常过滤器
- ✅ **请求日志** - 自动记录所有请求和响应时间
- ✅ **数据验证** - 使用 class-validator 自动验证 DTO
- ✅ **测试就绪** - Jest 测试配置和示例测试

### 生产就绪
- ✅ **Docker 支持** - 完整的 Docker 和 docker-compose 配置
- ✅ **健康检查** - 应用程序监控端点
- ✅ **分页支持** - 内置分页 DTO 和响应格式
- ✅ **Prisma 就绪** - 数据库 ORM 配置（需要 PostgreSQL）

## 📁 项目结构（企业级最佳实践）

```
src/
├── prisma/               # 🗄️ 数据库层（全局）
│   ├── prisma.service.ts # Prisma Client（单例）
│   └── prisma.module.ts  # 全局数据库模块
│
├── auth/                  # 🔐 认证模块（JWT + Prisma）
│   ├── dto/              # 登录/注册 DTO
│   ├── guards/           # JWT 守卫
│   ├── strategies/       # Passport JWT 策略
│   ├── auth.controller.ts
│   ├── auth.service.ts   # 使用 Prisma
│   └── auth.module.ts
│
├── common/                # 共享模块
│   ├── decorators/        # 自定义装饰器
│   ├── dto/              # 通用 DTO（分页等）
│   ├── filters/          # 异常过滤器
│   │   ├── http-exception.filter.ts
│   │   └── prisma-exception.filter.ts  # ⭐ Prisma 错误处理
│   ├── guards/           # 守卫（认证/授权）
│   └── interceptors/     # 拦截器（日志、转换）
│
├── config/               # 配置管理
│   ├── configuration.ts  # 配置工厂
│   └── env.validation.ts # 环境变量验证
│
├── health/               # 健康检查
├── users/                # 👥 用户模块（Repository Pattern）
│   ├── dto/              # Swagger + Validation
│   ├── entities/         # 使用 Prisma 类型
│   ├── users.controller.ts
│   ├── users.service.ts  # ⭐ 使用 Prisma（真实数据库）
│   └── users.module.ts
│
├── products/             # 🛍️ 产品模块（分页 + Prisma）
│   ├── dto/
│   ├── entities/
│   ├── products.controller.ts
│   ├── products.service.ts  # ⭐ 使用 Prisma
│   └── products.module.ts
│
├── app.module.ts         # 根模块（Prisma + Rate Limiting）
└── main.ts              # 应用入口（Swagger + Prisma 过滤器）
```

**架构亮点**：
- ✅ **Repository Pattern** - 数据访问层抽象
- ✅ **Prisma ORM** - 类型安全的数据库操作
- ✅ **全局模块** - PrismaService 单例
- ✅ **异常过滤器** - 统一的 Prisma 错误处理
- ✅ **真实数据库** - PostgreSQL 持久化存储

详细架构说明请查看：**[ARCHITECTURE.md](./ARCHITECTURE.md)**

## 🚀 快速开始

### 1. 安装依赖

```bash
# 在 monorepo 根目录
pnpm install
```

### 2. 配置环境变量

```bash
cd packages/backend
cp .env.example .env
# 编辑 .env 文件，设置你的配置
```

### 3. 启动开发服务器

```bash
# 在 monorepo 根目录
pnpm dev:backend

# 或者在 backend 目录
cd packages/backend
pnpm dev
```

服务器将在 `http://localhost:3001` 启动。

### 4. 访问 API 文档

启动服务器后，打开浏览器访问：

**📚 Swagger UI**: http://localhost:3001/api/docs

这里可以：
- 查看所有 API 端点
- 测试 API
- 查看请求/响应格式
- 测试 JWT 认证

## 📝 API 端点

所有端点都有 `/api/v1` 前缀。

### Authentication (认证)

- `POST /api/v1/auth/register` - 注册新用户（返回 JWT）
- `POST /api/v1/auth/login` - 用户登录（返回 JWT）
- `GET /api/v1/auth/profile` - 获取当前用户信息（需要 JWT）

**登录示例：**

```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'

# 响应:
# {
#   "user": { "id": "1", "name": "John", "email": "john@example.com" },
#   "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
# }
```

**使用 JWT 访问受保护端点：**

```bash
curl http://localhost:3001/api/v1/auth/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Health Check

- `GET /api/v1/health` - 获取应用健康状态
- `GET /api/v1/health/ping` - 简单的 ping-pong 检查

### Users (CRUD 示例)

- `POST /api/v1/users` - 创建用户
- `GET /api/v1/users` - 获取所有用户
- `GET /api/v1/users/:id` - 获取单个用户
- `PATCH /api/v1/users/:id` - 更新用户
- `DELETE /api/v1/users/:id` - 删除用户

**创建用户示例：**

```bash
curl -X POST http://localhost:3001/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Products (分页示例)

- `POST /api/v1/products` - 创建产品
- `GET /api/v1/products?page=1&limit=10` - 获取产品列表（支持分页）
- `GET /api/v1/products/:id` - 获取单个产品
- `PATCH /api/v1/products/:id` - 更新产品
- `DELETE /api/v1/products/:id` - 删除产品

**分页查询示例：**

```bash
curl "http://localhost:3001/api/v1/products?page=1&limit=5"
```

## 🧪 测试

### 运行所有测试

```bash
pnpm test
```

### 运行测试并监听文件变化

```bash
pnpm test:watch
```

### 生成测试覆盖率报告

```bash
pnpm test:cov
```

### 运行 E2E 测试

```bash
pnpm test:e2e
```

## 🔧 开发指南

### 创建新模块

使用 NestJS CLI 快速生成模块：

```bash
cd packages/backend
nest g module feature-name
nest g controller feature-name
nest g service feature-name
```

### 添加数据验证

使用 `class-validator` 装饰器：

```typescript
import { IsNotEmpty, IsEmail, MinLength } from 'class-validator';

export class CreateUserDto {
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @IsNotEmpty()
  @MinLength(6)
  password: string;
}
```

### 访问配置

在任何模块中注入 `ConfigService`：

```typescript
import { ConfigService } from '@nestjs/config';

constructor(private configService: ConfigService) {}

// 使用
const port = this.configService.get('port');
const jwtSecret = this.configService.get('jwt.secret');
```

### 异常处理

使用 NestJS 内置异常：

```typescript
import { NotFoundException, BadRequestException } from '@nestjs/common';

throw new NotFoundException('User not found');
throw new BadRequestException('Invalid input');
```

## 🏗️ 架构模式

### 依赖注入

所有服务、控制器都通过构造函数注入依赖：

```typescript
@Injectable()
export class UsersService {
  constructor(
    private configService: ConfigService,
    // 添加更多依赖
  ) {}
}
```

### 分层架构

- **Controller** - 处理 HTTP 请求
- **Service** - 业务逻辑
- **Repository/Entity** - 数据访问层（未来集成数据库）
- **DTO** - 数据传输对象（验证和类型安全）

### 模块化

每个功能都是独立的模块，可以轻松导入和重用：

```typescript
@Module({
  imports: [UsersModule, ProductsModule],
  // ...
})
export class AppModule {}
```

## 🐳 Docker 部署

### 开发环境（使用 docker-compose）

```bash
# 启动所有服务（backend + PostgreSQL + Redis）
docker-compose -f docker-compose.dev.yml up

# 后台运行
docker-compose -f docker-compose.dev.yml up -d

# 停止
docker-compose -f docker-compose.dev.yml down
```

### 生产环境

```bash
# 构建生产镜像
docker build -t praxis-backend .

# 运行生产容器
docker-compose up -d

# 查看日志
docker-compose logs -f backend
```

### Docker 命令速查

```bash
# 查看运行中的容器
docker ps

# 进入容器
docker exec -it praxis-backend sh

# 查看数据库
docker exec -it praxis-postgres psql -U postgres -d praxis

# 查看 Redis
docker exec -it praxis-redis redis-cli
```

## 📦 数据库集成（可选）

### 使用 Prisma ORM

如果你想使用真实数据库替代内存存储：

1. **安装 PostgreSQL**（或使用 Docker）
2. **按照步骤集成 Prisma**

详细步骤请查看：**[PRISMA_SETUP.md](./PRISMA_SETUP.md)**

```bash
# 快速开始
pnpm add prisma @prisma/client
npx prisma generate
npx prisma migrate dev
```

## 📦 功能路线图

### ✅ 已完成
- ✅ JWT 认证系统
- ✅ Swagger API 文档
- ✅ Rate Limiting
- ✅ Docker 支持
- ✅ Prisma 配置（需要安装 PostgreSQL）

### 🚧 计划中
- [ ] **授权** - RBAC (Role-Based Access Control)
- [ ] **缓存** - Redis 集成
- [ ] **日志系统** - Pino 或 Winston
- [ ] **WebSocket** - 实时通信
- [ ] **文件上传** - Multer 集成
- [ ] **邮件服务** - 发送验证邮件

## 🔐 安全最佳实践

当前实现是为了演示。在生产环境中：

- ✅ 使用真实数据库（Prisma + PostgreSQL）
- ✅ 密码必须加密（bcrypt/argon2）
- ✅ 实现 JWT 认证
- ✅ 添加 Rate Limiting
- ✅ 使用 Helmet 增强安全性
- ✅ 验证所有输入
- ✅ 不暴露敏感错误信息
- ✅ 使用 HTTPS

## 📚 学习资源

- [NestJS 官方文档](https://docs.nestjs.com/)
- [TypeScript 手册](https://www.typescriptlang.org/docs/)
- [class-validator 文档](https://github.com/typestack/class-validator)
- [Dependency Injection 模式](https://docs.nestjs.com/fundamentals/custom-providers)

## 🤝 贡献

欢迎贡献！请遵循项目的代码风格和最佳实践。

## 📄 License

ISC
