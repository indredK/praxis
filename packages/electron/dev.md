# Electron 开发学习指南

## 简介
Electron 是一个使用 Web 技术（HTML、CSS 和 JavaScript）构建跨平台桌面应用程序的框架。它基于 Chromium 和 Node.js，让你可以使用前端技术栈开发原生桌面应用。

## 官方网站
- **官网**: https://www.electronjs.org/
- **文档**: https://www.electronjs.org/docs
- **GitHub**: https://github.com/electron/electron

## 核心概念

### 主进程 (Main Process)
- 控制应用程序的生命周期
- 创建和管理渲染进程
- 处理系统级 API
- 管理菜单、对话框等

### 渲染进程 (Renderer Process)
- 显示用户界面
- 运行前端代码
- 通过 IPC 与主进程通信

### 预加载脚本 (Preload Scripts)
- 在渲染进程中运行
- 安全地暴露 Node.js API
- 桥接主进程和渲染进程

## 学习路径

### 1. 基础入门
- [ ] 了解 Electron 架构和工作原理
- [ ] 学习主进程和渲染进程的区别
- [ ] 掌握 IPC（进程间通信）机制

### 2. 环境搭建
- [ ] 安装 Node.js 和 npm
- [ ] 创建第一个 Electron 应用
- [ ] 配置开发环境

### 3. 核心功能
- [ ] 窗口管理（创建、关闭、最小化）
- [ ] 菜单和快捷键
- [ ] 对话框（文件选择、消息框）
- [ ] 系统托盘
- [ ] 自动更新

### 4. 进阶功能
- [ ] 原生模块集成
- [ ] 安全最佳实践
- [ ] 性能优化
- [ ] 打包和分发

## 推荐资源

### 官方资源
- [Electron 官方文档](https://www.electronjs.org/docs)
- [Electron 示例应用](https://github.com/electron/electron-quick-start)
- [Electron API 演示](https://github.com/electron/electron-api-demos)

### 学习教程
- [Electron 从入门到实践](https://www.electronjs.org/docs/tutorial/quick-start)
- [Electron 安全指南](https://www.electronjs.org/docs/tutorial/security)
- [Electron 性能优化](https://www.electronjs.org/docs/tutorial/performance)

### 社区资源
- [Electron 中文文档](https://electronjs.org/docs/zh-cn/)
- [Electron 社区](https://discuss.atom.io/c/electron)

## 常用工具

### 开发工具
- **Electron Forge**: 项目脚手架和构建工具
- **Electron Builder**: 应用打包和分发
- **Electron DevTools**: 调试工具

### 安装命令
```bash
# 全局安装 Electron CLI
npm install -g electron

# 创建新项目
npx create-electron-app my-app

# 使用 Electron Forge
npx create-electron-app my-app --template=webpack
```

## 项目结构示例
```
my-electron-app/
├── main.js          # 主进程文件
├── preload.js       # 预加载脚本
├── renderer/        # 渲染进程文件
│   ├── index.html
│   ├── style.css
│   └── renderer.js
├── package.json
└── README.md
```

## 学习目标
- [ ] 能够创建基本的 Electron 应用
- [ ] 理解主进程和渲染进程的通信机制
- [ ] 掌握窗口管理和系统集成
- [ ] 能够打包和分发应用
- [ ] 了解安全最佳实践

## 实践项目建议
1. **待办事项应用**: 创建一个桌面待办事项管理器
2. **文件管理器**: 实现基本的文件浏览功能
3. **系统监控工具**: 显示系统资源使用情况
4. **Markdown 编辑器**: 支持实时预览的编辑器

## 注意事项
- 注意应用的安全性，避免暴露 Node.js API
- 合理使用预加载脚本
- 考虑应用的性能和内存使用
- 遵循平台特定的设计规范
