# uni-app 开发学习指南

## 简介
uni-app 是 DCloud 开发的跨平台应用开发框架，使用 Vue.js 语法开发，一套代码可以发布到 iOS、Android、H5、各种小程序、快应用等多个平台。uni-app 是目前国内最流行的跨平台开发框架之一。

## 官方网站
- **官网**: https://uniapp.dcloud.net.cn/
- **HBuilderX**: https://www.dcloud.io/hbuilderx.html
- **文档**: https://uniapp.dcloud.net.cn/
- **GitHub**: https://github.com/dcloudio/uni-app

## 核心概念

### 多端适配
- 一套代码，多端运行
- 条件编译处理平台差异
- 自动适配不同平台的 API

### Vue.js 语法
- 基于 Vue.js 2.x 语法
- 支持 Vue 3.0 Composition API
- 组件化开发模式

### 原生渲染
- 使用原生组件渲染
- 接近原生的性能表现
- 支持原生插件扩展

## 学习路径

### 1. 基础入门
- [ ] 了解 uni-app 架构和多端适配原理
- [ ] 学习 Vue.js 基础（如果还不熟悉）
- [ ] 理解小程序开发基础

### 2. 环境搭建
- [ ] 安装 HBuilderX 或使用 CLI
- [ ] 创建第一个 uni-app 项目
- [ ] 配置开发环境
- [ ] 安装各平台开发者工具

### 3. 基础开发
- [ ] 基础组件（view、text、image、scroll-view）
- [ ] 样式系统和布局
- [ ] 用户输入（input、button、picker）
- [ ] 列表组件（scroll-view、swiper）

### 4. 路由和导航
- [ ] uni-app 页面路由
- [ ] 页面跳转和传参
- [ ] TabBar 配置
- [ ] 自定义导航栏

### 5. 状态管理
- [ ] Vuex 状态管理
- [ ] Pinia 状态管理（Vue 3）
- [ ] 组件间通信
- [ ] 全局数据管理

### 6. 进阶功能
- [ ] 网络请求（uni.request）
- [ ] 本地存储（uni.setStorage）
- [ ] 文件上传下载
- [ ] 地理位置服务
- [ ] 支付功能
- [ ] 分享功能
- [ ] 原生插件开发

## 推荐资源

### 官方资源
- [uni-app 官方文档](https://uniapp.dcloud.net.cn/)
- [uni-app 示例项目](https://github.com/dcloudio/uni-app/tree/master/examples)
- [uni-ui 组件库](https://uniapp.dcloud.net.cn/component/uniui/uni-ui.html)

### 学习教程
- [uni-app 快速开始](https://uniapp.dcloud.net.cn/quickstart.html)
- [uni-app 最佳实践](https://uniapp.dcloud.net.cn/tutorial/syntax-best-practice.html)
- [uni-app 多端开发指南](https://uniapp.dcloud.net.cn/tutorial/platform.html)

### 社区资源
- [DCloud 社区](https://ask.dcloud.net.cn/)
- [uni-app 插件市场](https://ext.dcloud.net.cn/)
- [uni-app 学习视频](https://ke.qq.com/course/3169971)

## 开发工具

### IDE 和编辑器
- **HBuilderX**: 官方推荐 IDE，功能完整
- **VS Code**: 轻量级编辑器，插件支持
- **WebStorm**: JetBrains 专业 IDE

### 调试工具
- **HBuilderX 内置调试器**: 官方调试工具
- **Chrome DevTools**: H5 端调试
- **各平台开发者工具**: 小程序端调试

### 安装命令
```bash
# 全局安装 uni-app CLI
npm install -g @dcloudio/uvm
uvm ls

# 创建新项目
vue create -p dcloudio/uni-preset-vue my-project

# 或使用 HBuilderX 创建项目
# 文件 -> 新建 -> 项目 -> uni-app
```

## 项目结构示例
```
my-project/
├── pages/                # 页面文件
│   ├── index/
│   │   ├── index.vue
│   │   └── index.nvue
├── components/           # 自定义组件
├── static/               # 静态资源
├── store/                # 状态管理
├── utils/                # 工具函数
├── pages.json            # 页面配置
├── manifest.json         # 应用配置
├── App.vue               # 应用入口
├── main.js               # 入口文件
└── uni.scss              # 全局样式
```

## 学习目标
- [ ] 掌握 uni-app 基础组件和 API
- [ ] 能够构建多端应用
- [ ] 理解不同平台的差异和适配
- [ ] 掌握路由和状态管理
- [ ] 能够处理网络请求和本地存储
- [ ] 了解各平台特定功能集成
- [ ] 掌握调试和性能优化技巧

## 实践项目建议
1. **待办事项应用**: 学习基础组件和状态管理
2. **新闻阅读器**: 集成网络 API 和列表展示
3. **电商应用**: 学习支付、分享等复杂功能
4. **社交应用**: 综合运用各种 uni-app 技术
5. **工具类应用**: 集成平台特定功能

## 常用库推荐

### UI 组件库
- **uni-ui**: 官方 UI 组件库
- **uView**: 全面兼容 uni-app 的 UI 框架
- **ColorUI**: 鲜亮的高饱和色彩，专注视觉的小程序组件库

### 工具库
- **uni-simple-router**: uni-app 路由管理
- **uni-request**: 网络请求库
- **uni-storage**: 本地存储库

## 平台支持

### 小程序平台
- 微信小程序
- 支付宝小程序
- 百度小程序
- 字节跳动小程序
- QQ 小程序
- 快手小程序

### 其他平台
- H5（Web）
- App（iOS/Android）
- 快应用
- 鸿蒙应用

## 注意事项
- 理解不同平台的 API 差异
- 注意样式在不同平台的兼容性
- 合理使用条件编译处理平台差异
- 遵循各平台的设计规范
- 重视性能优化和包体积控制
- 注意小程序的生命周期管理
- 了解原生插件开发和使用
