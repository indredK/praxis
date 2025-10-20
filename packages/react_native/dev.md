# React Native 开发学习指南

## 简介
React Native 是 Facebook 开发的跨平台移动应用开发框架，使用 React 和 JavaScript 构建原生移动应用。它允许开发者使用 Web 技术栈开发 iOS 和 Android 应用，同时保持接近原生的性能。

## 官方网站
- **官网**: https://reactnative.dev/
- **中文官网**: https://reactnative.cn/
- **文档**: https://reactnative.dev/docs/getting-started
- **GitHub**: https://github.com/facebook/react-native

## 核心概念

### 组件 (Components)
- 使用 React 组件构建 UI
- 原生组件映射到平台特定控件
- 自定义组件和第三方组件库

### 样式 (Styling)
- 类似 CSS 的样式系统
- Flexbox 布局
- 平台特定样式适配

### 导航 (Navigation)
- React Navigation 库
- 堆栈导航、标签导航、抽屉导航
- 深度链接和状态管理

## 学习路径

### 1. 基础入门
- [ ] 了解 React Native 架构和工作原理
- [ ] 学习 React 基础（如果还不熟悉）
- [ ] 理解原生组件和 JavaScript 桥接

### 2. 环境搭建
- [ ] 安装 Node.js 和 npm/yarn
- [ ] 配置 Android Studio 和 Xcode
- [ ] 安装 React Native CLI
- [ ] 创建第一个 React Native 应用

### 3. 基础开发
- [ ] 基础组件（View、Text、Image、ScrollView）
- [ ] 样式系统和布局
- [ ] 用户输入（TextInput、Button、TouchableOpacity）
- [ ] 列表组件（FlatList、SectionList）

### 4. 导航和路由
- [ ] React Navigation 安装和配置
- [ ] 堆栈导航器
- [ ] 标签导航器
- [ ] 抽屉导航器
- [ ] 导航参数传递

### 5. 状态管理
- [ ] React Hooks（useState、useEffect）
- [ ] Context API
- [ ] Redux 状态管理
- [ ] MobX 状态管理

### 6. 进阶功能
- [ ] 网络请求（Fetch、Axios）
- [ ] 本地存储（AsyncStorage、SQLite）
- [ ] 推送通知
- [ ] 相机和图片处理
- [ ] 地理位置服务
- [ ] 原生模块集成

## 推荐资源

### 官方资源
- [React Native 官方文档](https://reactnative.dev/docs/getting-started)
- [React Native 示例应用](https://github.com/facebook/react-native/tree/main/packages/react-native/template)
- [React Native 中文文档](https://reactnative.cn/docs/getting-started)

### 学习教程
- [React Native 官方教程](https://reactnative.dev/docs/tutorial)
- [React 官方教程](https://react.dev/learn)
- [React Native 实战教程](https://reactnative.cn/docs/tutorial)

### 社区资源
- [React Native 中文网](https://reactnative.cn/)
- [React Native 社区](https://reactnative.dev/community/overview)
- [React Native 中文社区](https://reactnative.cn/community/overview)

## 开发工具

### IDE 和编辑器
- **VS Code**: 推荐，插件丰富
- **WebStorm**: JetBrains 专业 IDE
- **Sublime Text**: 轻量级编辑器

### 调试工具
- **React Native Debugger**: 强大的调试工具
- **Flipper**: Facebook 的移动开发调试平台
- **Chrome DevTools**: 网络和性能调试

### 安装命令
```bash
# 安装 React Native CLI
npm install -g react-native-cli

# 创建新项目
npx react-native init MyApp

# 运行 Android 应用
npx react-native run-android

# 运行 iOS 应用
npx react-native run-ios

# 启动 Metro  bundler
npx react-native start
```

## 项目结构示例
```
MyApp/
├── android/               # Android 平台代码
├── ios/                   # iOS 平台代码
├── src/
│   ├── components/        # 可复用组件
│   ├── screens/          # 页面组件
│   ├── navigation/        # 导航配置
│   ├── services/          # API 服务
│   ├── utils/             # 工具函数
│   └── store/             # 状态管理
├── package.json
└── README.md
```

## 学习目标
- [ ] 掌握 React Native 基础组件
- [ ] 能够构建复杂的移动应用界面
- [ ] 掌握导航和路由管理
- [ ] 理解状态管理方案
- [ ] 能够处理网络请求和本地存储
- [ ] 了解平台特定功能集成
- [ ] 掌握调试和性能优化技巧

## 实践项目建议
1. **待办事项应用**: 学习基础组件和状态管理
2. **新闻阅读器**: 集成网络 API 和列表展示
3. **聊天应用**: 学习实时通信和复杂 UI
4. **电商应用**: 综合运用各种 React Native 技术
5. **健身追踪应用**: 集成传感器和本地存储

## 常用库推荐

### UI 组件库
- **React Native Elements**: 跨平台 UI 组件库
- **NativeBase**: 移动优先的组件库
- **UI Kitten**: 基于 Eva Design 的组件库

### 导航库
- **React Navigation**: 官方推荐的导航库
- **React Native Navigation**: 原生导航解决方案

### 状态管理
- **Redux**: 可预测的状态容器
- **MobX**: 简单可扩展的状态管理
- **Zustand**: 轻量级状态管理

## 注意事项
- 理解原生组件和 JavaScript 的性能差异
- 合理使用 Bridge 通信
- 注意内存管理和性能优化
- 遵循平台特定的设计规范
- 考虑不同屏幕尺寸和设备的适配
- 重视用户体验和性能表现
