# @praxis/backend

企业级 NestJS 后端服务，集成到 Praxis monorepo。

## 🎯 特性

- ✅ **TypeScript** - 完整的类型安全
- ✅ **依赖注入** - NestJS 强大的 DI 系统
- ✅ **模块化架构** - 按功能组织的清晰结构
- ✅ **配置管理** - 环境变量验证和类型安全配置
- ✅ **全局错误处理** - 统一的异常过滤器
- ✅ **请求日志** - 自动记录所有请求和响应时间
- ✅ **数据验证** - 使用 class-validator 自动验证 DTO
- ✅ **CORS 支持** - 配置化的跨域资源共享
- ✅ **健康检查** - 应用程序监控端点
- ✅ **分页支持** - 内置分页 DTO 和响应格式
- ✅ **测试就绪** - Jest 测试配置和示例测试

## 📁 项目结构

```
src/
├── common/                # 共享模块
│   ├── decorators/        # 自定义装饰器
│   ├── dto/              # 通用 DTO（分页等）
│   ├── filters/          # 全局异常过滤器
│   ├── guards/           # 守卫（认证/授权）
│   └── interceptors/     # 拦截器（日志、转换）
├── config/               # 配置模块
│   ├── configuration.ts  # 配置工厂
│   └── env.validation.ts # 环境变量验证
├── health/               # 健康检查模块
├── users/                # 用户模块（CRUD 示例）
│   ├── dto/
│   ├── entities/
│   ├── users.controller.ts
│   ├── users.service.ts
│   └── users.module.ts
├── products/             # 产品模块（分页示例）
│   ├── dto/
│   ├── entities/
│   ├── products.controller.ts
│   ├── products.service.ts
│   └── products.module.ts
├── app.module.ts         # 根模块
└── main.ts              # 应用入口
```

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

## 📝 API 端点

所有端点都有 `/api/v1` 前缀。

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

## 📦 下一步计划

- [ ] **数据库集成** - Prisma 或 TypeORM
- [ ] **认证系统** - JWT + Passport.js
- [ ] **授权** - RBAC (Role-Based Access Control)
- [ ] **API 文档** - Swagger/OpenAPI
- [ ] **限流** - Rate limiting
- [ ] **缓存** - Redis 集成
- [ ] **日志系统** - Pino 或 Winston
- [ ] **Docker 支持** - Dockerfile 和 docker-compose

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
