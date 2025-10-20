# Flutter 开发学习指南

## 简介
Flutter 是 Google 开发的跨平台 UI 框架，使用 Dart 语言编写。它允许开发者使用单一代码库构建高质量的原生应用，支持 iOS、Android、Web、Windows、macOS 和 Linux 平台。

## 官方网站
- **官网**: https://flutter.dev/
- **中文官网**: https://flutter.cn/
- **文档**: https://docs.flutter.dev/
- **GitHub**: https://github.com/flutter/flutter

## 核心概念

### Widget
- Flutter 中一切皆 Widget
- 分为 StatelessWidget 和 StatefulWidget
- 组合式设计，通过嵌套构建 UI

### State 管理
- State 控制 Widget 的行为和外观
- setState() 触发重建
- 状态提升和状态管理方案

### 渲染引擎
- Skia 图形引擎
- 自绘 UI，不依赖平台控件
- 高性能的 60fps 渲染

## 学习路径

### 1. 基础入门
- [ ] 了解 Flutter 架构和设计理念
- [ ] 学习 Dart 语言基础
- [ ] 理解 Widget 树和渲染机制

### 2. 环境搭建
- [ ] 安装 Flutter SDK
- [ ] 配置开发环境（Android Studio / VS Code）
- [ ] 创建第一个 Flutter 应用

### 3. UI 开发
- [ ] 基础 Widget（Text、Container、Row、Column）
- [ ] 布局 Widget（Flex、Stack、Positioned）
- [ ] 交互 Widget（Button、TextField、ListView）
- [ ] 自定义 Widget

### 4. 状态管理
- [ ] StatefulWidget 和 setState
- [ ] Provider 状态管理
- [ ] Riverpod 状态管理
- [ ] Bloc 状态管理

### 5. 进阶功能
- [ ] 网络请求和数据处理
- [ ] 本地存储（SharedPreferences、SQLite）
- [ ] 路由导航
- [ ] 动画和手势
- [ ] 平台特定功能

## 推荐资源

### 官方资源
- [Flutter 官方文档](https://docs.flutter.dev/)
- [Flutter 示例应用](https://github.com/flutter/samples)
- [Flutter 中文文档](https://flutter.cn/docs)

### 学习教程
- [Flutter 官方教程](https://docs.flutter.dev/get-started/codelab)
- [Dart 语言教程](https://dart.dev/guides/language)
- [Flutter 实战](https://book.flutterchina.club/)

### 社区资源
- [Flutter 中文网](https://flutterchina.club/)
- [Flutter 社区](https://flutter.dev/community)
- [Flutter 中文社区](https://flutterchina.club/community/)

## 开发工具

### IDE 和编辑器
- **Android Studio**: 官方推荐，功能完整
- **VS Code**: 轻量级，插件丰富
- **IntelliJ IDEA**: 专业版支持

### 调试工具
- **Flutter Inspector**: UI 调试工具
- **Dart DevTools**: 性能分析工具
- **Hot Reload**: 热重载功能

### 安装命令
```bash
# 检查 Flutter 环境
flutter doctor

# 创建新项目
flutter create my_app

# 运行应用
flutter run

# 构建应用
flutter build apk  # Android
flutter build ios  # iOS
flutter build web  # Web
```

## 项目结构示例
```
my_flutter_app/
├── lib/
│   ├── main.dart           # 应用入口
│   ├── models/            # 数据模型
│   ├── screens/           # 页面
│   ├── widgets/           # 自定义组件
│   └── services/          # 服务层
├── test/                  # 测试文件
├── android/               # Android 平台代码
├── ios/                   # iOS 平台代码
├── web/                   # Web 平台代码
└── pubspec.yaml           # 依赖配置
```

## 学习目标
- [ ] 掌握 Dart 语言基础
- [ ] 理解 Flutter Widget 体系
- [ ] 能够构建复杂的 UI 界面
- [ ] 掌握状态管理方案
- [ ] 能够处理网络请求和本地存储
- [ ] 了解平台特定功能集成

## 实践项目建议
1. **计数器应用**: 经典的 Flutter 入门项目
2. **待办事项应用**: 学习状态管理和数据持久化
3. **天气应用**: 集成网络 API 和地理位置
4. **聊天应用**: 学习实时通信和复杂 UI
5. **电商应用**: 综合运用各种 Flutter 技术

## 注意事项
- 理解 Widget 的不可变性
- 合理使用 State 管理
- 注意性能优化，避免不必要的重建
- 遵循 Material Design 或 Cupertino 设计规范
- 考虑不同平台的用户体验差异
