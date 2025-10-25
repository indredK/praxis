# 🧪 快速测试Mock数据标识

## 🎯 立即查看效果

### 方法1: 手动启用Mock模式（最简单）

**步骤：**
1. 打开文件：`packages/flutter/flutter_application_1/lib/config/api_config.dart`
2. 修改第15行：
   ```dart
   static const bool useMockData = true; // 改为true
   ```
3. 保存文件
4. Flutter会自动热重载
5. 查看应用界面

**预期结果：**
```
产品列表显示：

🔧 [Mock] iPhone 15 Pro Max
🔧 [Mock] Galaxy S24 Ultra  
🔧 [Mock] Pixel 8 Pro
🔧 [Mock] Tesla Model 3
```

### 方法2: 停止后端（测试自动降级）

**步骤：**
1. 确保 `useMockData = false`
2. 停止后端：
   ```bash
   lsof -ti:3001 | xargs kill -9
   ```
3. 刷新Flutter应用
4. 打开浏览器控制台（F12）

**预期结果：**
- 控制台显示：`⚠️ 后端请求失败，使用Mock数据`
- 产品名称显示：`🔧 [Mock] iPhone 15 Pro Max`

### 方法3: 对比真实数据

**步骤：**
1. 启动后端：
   ```bash
   cd /Users/kindred/Desktop/web/praxis
   pnpm dev:backend
   ```
2. 设置 `useMockData = false`
3. 刷新应用

**预期结果：**
```
产品列表显示（无Mock标识）：

iPhone 15 Pro Max
MacBook Pro 16" (M3 Pro)
iPad Pro 11" (M4)
```

## 📊 对比效果

### 真实后端数据
```
┌────────────────────────────┐
│ iPhone 15 Pro Max         │
│ Apple • 手机               │
│ ¥9,999                    │
└────────────────────────────┘
```

### Mock假数据
```
┌────────────────────────────┐
│ 🔧 [Mock] Galaxy S24 Ultra│
│ Samsung • 手机             │
│ ¥8,999                    │
└────────────────────────────┘
```

## 🔍 验证清单

- [ ] Mock模式下，所有产品名称都有 `🔧 [Mock]` 前缀
- [ ] 真实后端模式下，产品名称无前缀
- [ ] 后端失败时，自动显示Mock标识
- [ ] 搜索结果中也显示正确的标识
- [ ] 产品对比页面显示正确的标识

## 💡 提示

- **开发阶段**：建议设置 `useMockData = true`，使用Mock数据开发
- **测试阶段**：设置 `useMockData = false`，测试真实后端
- **演示阶段**：根据需要切换，展示不同数据源

## 🎊 完成！

现在你可以：
1. ✅ 一眼识别数据来源
2. ✅ 快速切换真假数据
3. ✅ 保证数据的可追溯性
4. ✅ 提升开发调试效率

**试试看效果吧！** 🚀

