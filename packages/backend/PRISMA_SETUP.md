# Prisma 数据库集成指南

本文档说明如何将 Prisma ORM 集成到后端服务。

## 📋 前置要求

### 1. 安装 PostgreSQL

**macOS (使用 Homebrew):**
```bash
brew install postgresql@16
brew services start postgresql@16
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
```

**Windows:**
- 下载 PostgreSQL: https://www.postgresql.org/download/windows/
- 或使用 Docker (推荐):
  ```bash
  docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16-alpine
  ```

### 2. 验证 PostgreSQL 安装

```bash
psql --version
# 或使用 Docker
docker exec -it postgres psql -U postgres
```

## 🚀 快速开始

### 步骤 1: 安装 Prisma

```bash
cd packages/backend
pnpm add prisma @prisma/client
pnpm add -D prisma
```

### 步骤 2: 更新 .env 文件

确保 `.env` 中有正确的数据库连接字符串：

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/praxis?schema=public"
```

### 步骤 3: 初始化 Prisma（如果还没有 schema）

```bash
# 如果已有 schema.prisma，跳过此步
npx prisma init
```

### 步骤 4: 生成 Prisma Client

```bash
npx prisma generate
```

### 步骤 5: 创建数据库和表

```bash
# 运行迁移
npx prisma migrate dev --name init

# 或者直接推送 schema（开发环境）
npx prisma db push
```

### 步骤 6: （可选）填充测试数据

```bash
# 创建 seed 脚本
npx prisma db seed
```

## 📝 在代码中使用 Prisma

### 1. 创建 Prisma Service

创建 `src/prisma/prisma.service.ts`:

```typescript
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
```

创建 `src/prisma/prisma.module.ts`:

```typescript
import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
```

### 2. 在 AppModule 中导入

```typescript
// src/app.module.ts
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [
    // ... other imports
    PrismaModule,
  ],
})
export class AppModule {}
```

### 3. 在 Service 中使用

```typescript
// src/users/users.service.ts
import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersService {
  constructor(private prisma: PrismaService) {}

  async create(data: CreateUserDto) {
    return this.prisma.user.create({
      data: {
        name: data.name,
        email: data.email,
        password: data.password, // 记得加密！
      },
    });
  }

  async findAll() {
    return this.prisma.user.findMany({
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        updatedAt: true,
        // 不返回 password
      },
    });
  }

  async findOne(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  async update(id: string, data: UpdateUserDto) {
    return this.prisma.user.update({
      where: { id },
      data,
    });
  }

  async remove(id: string) {
    return this.prisma.user.delete({
      where: { id },
    });
  }
}
```

## 🐳 使用 Docker 运行数据库

### 单独运行 PostgreSQL:

```bash
docker run --name praxis-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=praxis \
  -p 5432:5432 \
  -d postgres:16-alpine
```

### 使用 docker-compose（包含 Redis）:

```bash
# 启动所有服务
docker-compose up -d

# 只启动数据库
docker-compose up -d postgres redis
```

## 📚 常用 Prisma 命令

```bash
# 生成 Prisma Client
npx prisma generate

# 创建迁移
npx prisma migrate dev --name migration_name

# 重置数据库（危险！）
npx prisma migrate reset

# 打开 Prisma Studio（数据库 GUI）
npx prisma studio

# 验证 schema
npx prisma validate

# 格式化 schema
npx prisma format

# 查看迁移状态
npx prisma migrate status

# 应用迁移到生产环境
npx prisma migrate deploy
```

## 🔄 迁移现有代码到 Prisma

### 1. 替换内存存储为 Prisma

将 `UsersService` 中的数组替换为 Prisma 查询：

**Before (内存存储):**
```typescript
private users: User[] = [];
```

**After (Prisma):**
```typescript
constructor(private prisma: PrismaService) {}
```

### 2. 更新认证服务

在 `AuthService` 中使用 Prisma 查询用户：

```typescript
async findUserWithPassword(email: string) {
  return this.prisma.user.findUnique({
    where: { email },
  });
}
```

## 🎯 最佳实践

1. **始终使用迁移** - 不要在生产环境使用 `db push`
2. **选择性查询** - 使用 `select` 避免返回敏感数据
3. **事务处理** - 对复杂操作使用 `$transaction`
4. **错误处理** - 捕获 Prisma 特定错误（P2002 等）
5. **性能优化** - 使用 `include` 和 `select` 优化查询

## 🔗 相关资源

- [Prisma 文档](https://www.prisma.io/docs)
- [NestJS Prisma 集成](https://docs.nestjs.com/recipes/prisma)
- [Prisma Schema 参考](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)

## ❓ 常见问题

**Q: 如何处理 Prisma 错误码？**

```typescript
import { Prisma } from '@prisma/client';

catch (error) {
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    // P2002: Unique constraint violation
    if (error.code === 'P2002') {
      throw new ConflictException('Email already exists');
    }
    // P2025: Record not found
    if (error.code === 'P2025') {
      throw new NotFoundException('User not found');
    }
  }
  throw error;
}
```

**Q: 如何在测试中使用 Prisma？**

使用测试数据库或 Docker 容器，每次测试后清理数据。

**Q: 生产环境如何运行迁移？**

```bash
npx prisma migrate deploy
```

## 🎉 完成！

配置完成后，你将拥有：
- ✅ 类型安全的数据库查询
- ✅ 自动生成的迁移
- ✅ 强大的查询构建器
- ✅ 优秀的开发体验

