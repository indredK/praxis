# 🏗️ 架构设计 - 业内最佳实践

本文档详细说明了后端服务的架构设计，遵循**业内最佳实践**。

## 📊 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                     Client (HTTP/HTTPS)                      │
└────────────────────────────┬────────────────────────────────┘
                             │
                  ┌──────────▼──────────┐
                  │   API Gateway       │
                  │   (NestJS App)      │
                  │   Port: 3001        │
                  └──────────┬──────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌────▼────┐         ┌────▼────┐
   │ Guards  │         │ Pipes   │         │ Filters │
   │ (Auth)  │         │ (Valid) │         │ (Error) │
   └────┬────┘         └────┬────┘         └────┬────┘
        │                   │                    │
        └───────────────────┼────────────────────┘
                            │
                 ┌──────────▼──────────┐
                 │   Controllers       │
                 │   (Route Handlers)  │
                 └──────────┬──────────┘
                            │
                 ┌──────────▼──────────┐
                 │   Services          │
                 │   (Business Logic)  │
                 └──────────┬──────────┘
                            │
                 ┌──────────▼──────────┐
                 │   Prisma Service    │
                 │   (Data Access)     │
                 └──────────┬──────────┘
                            │
                 ┌──────────▼──────────┐
                 │   PostgreSQL        │
                 │   (Database)        │
                 └─────────────────────┘
```

## 🗂️ 项目结构（最佳实践）

```
src/
├── prisma/                    # 🗄️ 数据库层（全局）
│   ├── prisma.service.ts      # Prisma Client 管理
│   └── prisma.module.ts       # 全局数据库模块
│
├── common/                    # 🔧 共享模块
│   ├── decorators/            # 自定义装饰器
│   ├── dto/                   # 通用 DTO
│   │   └── pagination.dto.ts  # 分页
│   ├── filters/               # 异常过滤器
│   │   ├── http-exception.filter.ts
│   │   └── prisma-exception.filter.ts  # Prisma 错误处理
│   ├── guards/                # 守卫
│   │   └── jwt-auth.guard.ts
│   └── interceptors/          # 拦截器
│       ├── logging.interceptor.ts
│       └── transform.interceptor.ts
│
├── config/                    # ⚙️ 配置管理
│   ├── configuration.ts       # 配置工厂
│   └── env.validation.ts      # 环境变量验证
│
├── auth/                      # 🔐 认证模块
│   ├── dto/
│   │   ├── login.dto.ts
│   │   └── register.dto.ts
│   ├── guards/
│   │   └── jwt-auth.guard.ts
│   ├── strategies/
│   │   └── jwt.strategy.ts    # Passport JWT 策略
│   ├── auth.controller.ts     # 认证端点
│   ├── auth.service.ts        # 认证业务逻辑
│   └── auth.module.ts
│
├── users/                     # 👥 用户模块（领域模块示例）
│   ├── dto/
│   │   ├── create-user.dto.ts # Swagger + Validation
│   │   └── update-user.dto.ts
│   ├── entities/
│   │   └── user.entity.ts     # （使用 Prisma 类型）
│   ├── users.controller.ts    # RESTful API
│   ├── users.service.ts       # Repository Pattern
│   └── users.module.ts
│
├── products/                  # 🛍️ 产品模块（领域模块示例）
│   ├── dto/
│   ├── entities/
│   ├── products.controller.ts
│   ├── products.service.ts    # 含分页支持
│   └── products.module.ts
│
├── health/                    # ❤️ 健康检查
│   ├── health.controller.ts
│   ├── health.service.ts
│   └── health.module.ts
│
├── app.module.ts              # 根模块
└── main.ts                    # 应用入口
```

## 🎯 设计模式和最佳实践

### 1. **Repository Pattern（仓储模式）**

**为什么使用**：
- ✅ 将数据访问逻辑与业务逻辑分离
- ✅ 便于测试（可以 mock）
- ✅ 数据库无关性

**实现示例**：

```typescript
// users.service.ts - 充当 Repository
@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async findAll(): Promise<User[]> {
    return this.prisma.user.findMany();
  }
}
```

### 2. **Dependency Injection（依赖注入）**

**为什么使用**：
- ✅ 松耦合
- ✅ 易于测试
- ✅ 更好的代码组织

**实现示例**：

```typescript
@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,    // 自动注入
    private jwtService: JwtService,         // 自动注入
    private configService: ConfigService,   // 自动注入
  ) {}
}
```

### 3. **Global Module Pattern（全局模块）**

**为什么使用**：
- ✅ 避免重复导入
- ✅ 单例模式
- ✅ 资源共享（如数据库连接池）

**实现示例**：

```typescript
@Global()  // 全局可用
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
```

### 4. **DTO Pattern（数据传输对象）**

**为什么使用**：
- ✅ 输入验证
- ✅ 类型安全
- ✅ API 文档生成

**实现示例**：

```typescript
export class CreateUserDto {
  @ApiProperty({ example: 'John Doe' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ example: 'john@example.com' })
  @IsEmail()
  email: string;
}
```

### 5. **Exception Filter Pattern（异常过滤器）**

**为什么使用**：
- ✅ 集中错误处理
- ✅ 统一错误响应格式
- ✅ 隐藏敏感信息

**实现示例**：

```typescript
@Catch(Prisma.PrismaClientKnownRequestError)
export class PrismaClientExceptionFilter {
  catch(exception, host) {
    // P2002: Unique constraint violation
    if (exception.code === 'P2002') {
      return { status: 409, message: 'Email already exists' };
    }
  }
}
```

### 6. **Guard Pattern（守卫模式）**

**为什么使用**：
- ✅ 认证和授权
- ✅ 路由级别保护
- ✅ 可组合

**实现示例**：

```typescript
@Controller('users')
export class UsersController {
  @Get('profile')
  @UseGuards(JwtAuthGuard)  // 保护此路由
  getProfile(@Request() req) {
    return req.user;
  }
}
```

## 🔄 数据流

### 请求处理流程

```
1. HTTP Request
   ↓
2. Guards (认证/授权检查)
   ↓
3. Interceptors (前置：日志记录)
   ↓
4. Pipes (数据验证和转换)
   ↓
5. Controller (路由处理)
   ↓
6. Service (业务逻辑)
   ↓
7. Prisma Service (数据访问)
   ↓
8. PostgreSQL (数据库)
   ↓
9. Interceptors (后置：响应转换)
   ↓
10. Exception Filters (错误处理)
   ↓
11. HTTP Response
```

## 📚 分层架构

### Layer 1: Presentation Layer（表现层）
- **Controllers**: 处理 HTTP 请求和响应
- **DTOs**: 输入输出数据结构
- **Guards**: 认证授权
- **Interceptors**: 请求/响应处理

### Layer 2: Business Logic Layer（业务逻辑层）
- **Services**: 核心业务逻辑
- **Domain Logic**: 领域规则

### Layer 3: Data Access Layer（数据访问层）
- **Prisma Service**: ORM 操作
- **Database**: PostgreSQL

### Cross-Cutting Concerns（横切关注点）
- **Logging**: 日志记录
- **Error Handling**: 错误处理
- **Configuration**: 配置管理
- **Validation**: 数据验证

## 🔒 安全最佳实践

### 1. 密码处理
```typescript
// ✅ 好的做法
const hashedPassword = await bcrypt.hash(password, 10);

// ❌ 坏的做法
const password = plainTextPassword;  // 永远不要存储明文密码
```

### 2. 敏感数据保护
```typescript
// ✅ 好的做法：从返回结果中排除密码
return this.prisma.user.findMany({
  select: {
    id: true,
    name: true,
    email: true,
    // password 被排除
  },
});

// ❌ 坏的做法
return this.prisma.user.findMany();  // 包含密码！
```

### 3. JWT 令牌
```typescript
// ✅ 好的做法：使用环境变量
secret: configService.get('jwt.secret')

// ❌ 坏的做法
secret: 'hardcoded-secret'  // 永远不要硬编码密钥
```

## ⚡ 性能最佳实践

### 1. 并行查询
```typescript
// ✅ 好的做法：并行执行
const [total, products] = await Promise.all([
  this.prisma.product.count(),
  this.prisma.product.findMany(),
]);

// ❌ 坏的做法：串行执行
const total = await this.prisma.product.count();
const products = await this.prisma.product.findMany();
```

### 2. 选择性查询
```typescript
// ✅ 好的做法：只选择需要的字段
select: {
  id: true,
  name: true,
  email: true,
}

// ❌ 坏的做法：查询所有字段
// findMany() 会返回所有字段，包括不需要的
```

### 3. 分页
```typescript
// ✅ 好的做法：使用 skip/take
findMany({
  skip: (page - 1) * limit,
  take: limit,
})

// ❌ 坏的做法：查询所有然后切片
const all = await findMany();
return all.slice(start, end);
```

## 🧪 测试策略

### 1. 单元测试
- 测试 Services 的业务逻辑
- Mock Prisma Service
- 快速且独立

### 2. 集成测试
- 测试 Controllers + Services
- 使用测试数据库
- 真实的数据库交互

### 3. E2E 测试
- 测试完整的请求流程
- 模拟真实场景
- 验证整个系统

## 📖 代码组织原则

### 1. Single Responsibility（单一职责）
每个模块、类、函数只做一件事。

### 2. DRY（Don't Repeat Yourself）
避免代码重复，提取公共逻辑。

### 3. KISS（Keep It Simple, Stupid）
保持简单，避免过度设计。

### 4. Separation of Concerns（关注点分离）
- Controllers 处理 HTTP
- Services 处理业务逻辑
- Prisma 处理数据访问

## 🔧 配置管理最佳实践

### 1. 环境变量
```typescript
// ✅ 好的做法：使用 ConfigService
constructor(private config: ConfigService) {
  this.apiKey = config.get('API_KEY');
}

// ❌ 坏的做法：直接访问 process.env
const apiKey = process.env.API_KEY;
```

### 2. 验证
```typescript
// ✅ 好的做法：启动时验证
ConfigModule.forRoot({
  validate,  // 验证环境变量
})

// ❌ 坏的做法：运行时才发现配置错误
```

## 📈 扩展性考虑

### 1. 模块化
每个功能都是独立的模块，易于：
- 单独开发
- 单独测试
- 单独部署（微服务）

### 2. 松耦合
通过依赖注入实现松耦合：
- 易于替换实现
- 易于模拟测试
- 易于扩展

### 3. 可配置
所有配置都通过环境变量：
- 不同环境使用不同配置
- 不用修改代码
- 安全性更好

## 🎓 学习资源

- [NestJS 官方文档](https://docs.nestjs.com/)
- [Prisma 最佳实践](https://www.prisma.io/docs/guides/performance-and-optimization)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)

## ✅ 架构检查清单

当你添加新功能时，确保：

- [ ] **分层清晰**：Controller → Service → Prisma
- [ ] **类型安全**：使用 TypeScript 和 Prisma 类型
- [ ] **数据验证**：使用 DTO + class-validator
- [ ] **错误处理**：使用适当的异常
- [ ] **文档化**：Swagger 装饰器
- [ ] **测试覆盖**：至少单元测试
- [ ] **安全考虑**：不暴露敏感数据
- [ ] **性能优化**：避免 N+1 查询
- [ ] **日志记录**：重要操作有日志
- [ ] **配置管理**：使用 ConfigService

## 🎉 总结

这个架构遵循了：
- ✅ **SOLID 原则**
- ✅ **Clean Architecture**
- ✅ **Repository Pattern**
- ✅ **Dependency Injection**
- ✅ **NestJS 最佳实践**
- ✅ **Prisma 最佳实践**

这是一个**生产就绪、可扩展、易维护**的企业级架构！ 🚀

