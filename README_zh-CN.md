此文档也提供英文版本: [English](README.md)

# Praxis

[![npm version](https://badge.fury.io/js/@indredk%2Fpraxis.svg)](https://badge.fury.io/js/@indredk%2Fpraxis)
[![CI/CD](https://github.com/indredk/praxis/actions/workflows/release.yml/badge.svg)](https://github.com/indredk/praxis/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Praxis**: 一个将现代编程理论通过“人机协作”付诸实践的 TS 工具库。

## 简介 (Introduction)

Praxis 是一套功能强大、类型安全且经过充分测试的 TypeScript/JavaScript 工具函数库。它诞生于一段独特的开发者与 AI 协作的过程，旨在将异步控制、数据处理和函数式编程中的核心思想，转化为生产级的、易于使用的工具。

这个库中的每一个函数都经过了精心设计，不仅考虑了基本功能，也覆盖了各种复杂的边界情况，并附带了详尽的测试用例。

## 核心特性 (Core Features)

- **高级异步控制**: 包含 `pLimit` (并发控制), `asyncDebounce` (异步防抖), `withTimeout` (超时处理) 等。
- **函数式编程工具**: 提供了 `curry` (柯里化) 等工具，帮助您编写更优雅、可复用的代码。
- **深度数据操作**: 支持 `mergeObjects` (高度可配置的对象合并), `flatten` (对象扁平化) 等复杂的数据结构操作。
- **通用实用工具**: 提供了 `promisify` (Promise 转换器), `onceAsync` (异步单例模式) 等基础工具。

## 工具函数库功能总结

1. **mergeObjects**: 高度可配置地深度合并两个对象，支持自定义合并策略、路径过滤和数组处理。
2. **promisify**: 将遵循 Node.js 回调风格 (err, data) 的函数，转换为返回 Promise 的函数，支持 `this` 上下文和多返回值。
3. **asyncDebounce**: 创建一个异步防抖锁，确保一个异步函数在上次调用完成前不会再次执行，以防止并发冲突。
4. **withTimeout**: 为一个异步函数附加超时机制，如果操作在指定时间内未完成，则抛出 `TimeoutError`。
5. **onceAsyncWithReset**: 确保一个异步函数只执行一次，并提供 `.reset()` 方法来清除缓存，以适应不同生命周期的需求。
6. **pLimit**: 创建一个 Promise 并发控制器，用于限制同时运行的异步任务数量，以进行流量控制。
7. **curry**: 将一个多参数函数柯里化，使其可以分步、灵活地接收任意数量的参数，便于创建专用函数。
8. **flatten**: 将一个嵌套对象（包括数组）转换为一个键为路径字符串的扁平对象。
9. **unflatten**: 将一个键为路径字符串的扁平对象还原为原始的嵌套结构，并能智能识别数组。

## 安装 (Installation)

在您的项目中，使用 npm 或 yarn 安装 Praxis：

```bash
npm install @indredk/praxis
或

Bash

yarn add @indredk/praxis
快速上手 (Quick Start)
以下是一个使用 pLimit 并发控制器的简单示例，展示了如何同时执行多个异步任务，但限制并发数量。

TypeScript

import { pLimit } from '@indredk/praxis';

const runExample = async () => {
  const limit = pLimit(2); // 最多同时运行 2 个任务

  const tasks = [
    () => new Promise(resolve => setTimeout(() => { console.log('Task A finished!'); resolve('A'); }, 1000)),
    () => new Promise(resolve => setTimeout(() => { console.log('Task B finished!'); resolve('B'); }, 500)),
    () => new Promise(resolve => setTimeout(() => { console.log('Task C finished!'); resolve('C'); }, 1500)),
    () => new Promise(resolve => setTimeout(() => { console.log('Task D finished!'); resolve('D'); }, 800)),
  ];

  const results = await Promise.all(tasks.map(task => limit(task)));

  console.log('All tasks completed in order:', results);
};

runExample();

// 预期控制台输出:
// Task A finished!
// Task B finished!
// Task C finished!
// Task D finished!
// All tasks completed in order: [ 'A', 'B', 'C', 'D' ]
API 文档 (API Documentation)
我们为您生成的完整 API 文档，包含了所有函数、参数和返回值的详细说明。

在线文档: https://indredk.github.io/praxis/ （请确保已在 GitHub 上启用 Pages 服务）

本地查看: 在项目根目录下，用浏览器打开 ./docs/index.html 文件。

贡献 (Contributing)
欢迎任何形式的贡献，如果您发现 Bug 或有新的功能想法，请通过以下方式联系：

提交 Issue: https://github.com/indredk/praxis/issues

提交 Pull Request: https://github.com/indredk/praxis/pulls

在提交代码前，请确保您已阅读并遵守项目的 行为准则 和 贡献指南。

许可证 (License)
本项目采用 MIT 许可证。详见 LICENSE 文件。

致谢 (Acknowledgements)
本工具库的诞生，得益于对开源社区优秀思想的吸收与再创造。在此特别感谢：

Sindre Sorhus: 其 p-limit 等库的设计哲学，为本项目提供了核心灵感。

Hughsk: 其 flat 等库的实现，为本项目提供了参考。

Google's Gemini AI: 在整个设计、实现、调试和测试流程中，扮演了不可或缺的协作伙伴角色，将现代编程理论通过独特的“人机协作”付诸实践。
