# API 使用示例

本文档提供了所有 API 端点的详细使用示例。

## 基础 URL

```
http://localhost:3001/api/v1
```

## 🏥 健康检查 API

### 获取应用健康状态

```bash
curl http://localhost:3001/api/v1/health
```

**响应：**

```json
{
  "data": {
    "status": "ok",
    "timestamp": "2025-10-25T12:00:00.000Z",
    "uptime": 123.456,
    "environment": "development",
    "memory": {
      "total": 12345678,
      "used": 8765432
    }
  },
  "statusCode": 200,
  "message": "Success",
  "timestamp": "2025-10-25T12:00:00.000Z"
}
```

### Ping 检查

```bash
curl http://localhost:3001/api/v1/health/ping
```

## 👥 用户 API

### 1. 创建用户

```bash
curl -X POST http://localhost:3001/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "张三",
    "email": "zhangsan@example.com",
    "password": "password123"
  }'
```

**响应：**

```json
{
  "data": {
    "id": "1",
    "name": "张三",
    "email": "zhangsan@example.com",
    "createdAt": "2025-10-25T12:00:00.000Z",
    "updatedAt": "2025-10-25T12:00:00.000Z"
  },
  "statusCode": 201,
  "message": "Success",
  "timestamp": "2025-10-25T12:00:00.000Z"
}
```

### 2. 获取所有用户

```bash
curl http://localhost:3001/api/v1/users
```

**响应：**

```json
{
  "data": [
    {
      "id": "1",
      "name": "张三",
      "email": "zhangsan@example.com",
      "createdAt": "2025-10-25T12:00:00.000Z",
      "updatedAt": "2025-10-25T12:00:00.000Z"
    }
  ],
  "statusCode": 200,
  "message": "Success",
  "timestamp": "2025-10-25T12:00:00.000Z"
}
```

### 3. 获取单个用户

```bash
curl http://localhost:3001/api/v1/users/1
```

### 4. 更新用户

```bash
curl -X PATCH http://localhost:3001/api/v1/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "李四"
  }'
```

### 5. 删除用户

```bash
curl -X DELETE http://localhost:3001/api/v1/users/1
```

**响应：** 204 No Content

## 🛍️ 产品 API

### 1. 创建产品

```bash
curl -X POST http://localhost:3001/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "iPhone 15 Pro",
    "description": "最新款 iPhone",
    "price": 7999.00,
    "stock": 100
  }'
```

**响应：**

```json
{
  "data": {
    "id": "3",
    "name": "iPhone 15 Pro",
    "description": "最新款 iPhone",
    "price": 7999,
    "stock": 100,
    "createdAt": "2025-10-25T12:00:00.000Z",
    "updatedAt": "2025-10-25T12:00:00.000Z"
  },
  "statusCode": 201,
  "message": "Success",
  "timestamp": "2025-10-25T12:00:00.000Z"
}
```

### 2. 获取产品列表（带分页）

```bash
# 默认: page=1, limit=10
curl http://localhost:3001/api/v1/products

# 自定义分页
curl "http://localhost:3001/api/v1/products?page=1&limit=5"
```

**响应：**

```json
{
  "data": {
    "data": [
      {
        "id": "1",
        "name": "Sample Product 1",
        "description": "This is a sample product",
        "price": 99.99,
        "stock": 100,
        "createdAt": "2025-10-25T12:00:00.000Z",
        "updatedAt": "2025-10-25T12:00:00.000Z"
      }
    ],
    "meta": {
      "total": 10,
      "page": 1,
      "limit": 5,
      "totalPages": 2
    }
  },
  "statusCode": 200,
  "message": "Success",
  "timestamp": "2025-10-25T12:00:00.000Z"
}
```

### 3. 获取单个产品

```bash
curl http://localhost:3001/api/v1/products/1
```

### 4. 更新产品

```bash
curl -X PATCH http://localhost:3001/api/v1/products/1 \
  -H "Content-Type: application/json" \
  -d '{
    "price": 6999.00,
    "stock": 80
  }'
```

### 5. 删除产品

```bash
curl -X DELETE http://localhost:3001/api/v1/products/1
```

## ❌ 错误处理

### 验证错误 (400)

```bash
# 发送无效数据
curl -X POST http://localhost:3001/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "A",
    "email": "invalid-email",
    "password": "123"
  }'
```

**响应：**

```json
{
  "statusCode": 400,
  "timestamp": "2025-10-25T12:00:00.000Z",
  "path": "/api/v1/users",
  "method": "POST",
  "message": [
    "name must be longer than or equal to 2 characters",
    "email must be an email",
    "password must be longer than or equal to 6 characters"
  ]
}
```

### 资源未找到 (404)

```bash
curl http://localhost:3001/api/v1/users/999
```

**响应：**

```json
{
  "statusCode": 404,
  "timestamp": "2025-10-25T12:00:00.000Z",
  "path": "/api/v1/users/999",
  "method": "GET",
  "message": "User with ID 999 not found"
}
```

### 冲突错误 (409)

```bash
# 尝试创建重复邮箱的用户
curl -X POST http://localhost:3001/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "张三",
    "email": "zhangsan@example.com",
    "password": "password123"
  }'
```

**响应：**

```json
{
  "statusCode": 409,
  "timestamp": "2025-10-25T12:00:00.000Z",
  "path": "/api/v1/users",
  "method": "POST",
  "message": "Email already exists"
}
```

## 🧪 使用 JavaScript/TypeScript 调用

### Fetch API

```typescript
// 创建用户
const response = await fetch('http://localhost:3001/api/v1/users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    name: '张三',
    email: 'zhangsan@example.com',
    password: 'password123',
  }),
});

const data = await response.json();
console.log(data);
```

### Axios

```typescript
import axios from 'axios';

// 获取产品列表（带分页）
const { data } = await axios.get('http://localhost:3001/api/v1/products', {
  params: {
    page: 1,
    limit: 10,
  },
});

console.log(data.data.data); // 产品数组
console.log(data.data.meta); // 分页信息
```

## 📝 注意事项

1. 所有成功的响应都包装在统一的格式中：

   ```json
   {
     "data": {},
     "statusCode": 200,
     "message": "Success",
     "timestamp": "ISO 8601 timestamp"
   }
   ```

2. 所有错误响应都遵循一致的格式：

   ```json
   {
     "statusCode": 400,
     "timestamp": "ISO 8601 timestamp",
     "path": "/api/v1/endpoint",
     "method": "HTTP_METHOD",
     "message": "Error message or array of messages"
   }
   ```

3. 分页查询参数：
   - `page`: 页码（默认: 1）
   - `limit`: 每页数量（默认: 10，最大: 100）

