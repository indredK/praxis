#!/bin/bash

echo "📦 创建 Praxis 数据库..."

# 创建数据库
psql postgres -c "CREATE DATABASE praxis;" 2>/dev/null || echo "数据库可能已存在"

# 验证数据库
psql postgres -c "\l" | grep praxis

echo "✅ 数据库设置完成！"
