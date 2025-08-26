Read this in other languages: [中文](README_zh-CN.md)

# Praxis

[![npm version](https://badge.fury.io/js/@indredk%2Fpraxis.svg)](https://badge.fury.io/js/@indredk%2Fpraxis)
[![CI/CD](https://github.com/indredk/praxis/actions/workflows/release.yml/badge.svg)](https://github.com/indredk/praxis/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Praxis**: A TypeScript utility library where modern programming theory is put into practice through a developer-AI partnership.

## Introduction

Praxis is a collection of powerful, type-safe, and thoroughly tested TypeScript/JavaScript utility functions. It was born from a unique developer-AI collaboration, designed to transform core concepts from asynchronous control, data manipulation, and functional programming into production-grade, easy-to-use tools.

Each function in this library is meticulously crafted to handle not only its basic functionality but also complex edge cases, and comes with a comprehensive test suite to ensure its reliability.

## Core Features

- **Advanced Asynchronous Control**: Includes `pLimit` (concurrency control), `asyncDebounce` (asynchronous debounce), `withTimeout` (timeout handling), and more.
- **Functional Programming Tools**: Provides utilities like `curry` (currying) to help you write more elegant and reusable code.
- **Deep Data Operations**: Supports complex data structure operations such as `mergeObjects` (highly configurable object merging) and `flatten` (object flattening).
- **General Utilities**: Offers fundamental tools like `promisify` (Promise converter) and `onceAsync` (asynchronous singleton pattern).

## Tool Functions Summary

1. **mergeObjects**: Configurably deep merges two objects, supporting custom strategies, path filtering, and array handling.
2. **promisify**: Converts a Node.js callback-style function into a Promise-returning async function, supporting `this` context and multiple return values.
3. **asyncDebounce**: Creates an async debounce lock, ensuring an async function won't run again before the previous call completes, to prevent concurrent conflicts.
4. **withTimeout**: Adds a timeout mechanism to an async function, throwing a `TimeoutError` if the operation doesn't complete within the specified time.
5. **onceAsyncWithReset**: Ensures an async function runs only once, and provides a `.reset()` method to clear the cache for next use, adapting to different lifecycles.
6. **pLimit**: Creates a Promise concurrency limiter to restrict the number of async tasks running at the same time for flow control.
7. **curry**: Curries a multi-argument function, allowing it to receive arguments in a flexible, stepwise manner, for creating specialized functions.
8. **flatten**: Converts a nested object (including arrays) into a flat object with path-based keys.
9. **unflatten**: Restores a flat object to its original nested structure, with intelligent detection for arrays.

## Installation

Install Praxis in your project using npm or yarn:

```bash
npm install @indredk/praxis
or

Bash

yarn add @indredk/praxis
Quick Start
Here is a simple example using the pLimit concurrency controller, demonstrating how to execute multiple asynchronous tasks simultaneously while limiting the number of concurrent processes.

TypeScript

import { pLimit } from '@indredk/praxis';

const runExample = async () => {
  const limit = pLimit(2); // Maximum 2 concurrent tasks

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

// Expected console output:
// Task A finished!
// Task B finished!
// Task C finished!
// Task D finished!
// All tasks completed in order: [ 'A', 'B', 'C', 'D' ]
API Documentation
We have generated comprehensive API documentation for you, which includes detailed descriptions of all functions, parameters, and return values.

Online Documentation: https://indredk.github.io/praxis/ （Please ensure you have enabled Pages on GitHub）

Local Viewing: Open the ./docs/index.html file in your browser from the project root.

Contributing
We welcome all contributions. If you find a bug or have an idea for a new feature, please contact us via:

Submit an Issue: https://github.com/indredk/praxis/issues

Submit a Pull Request: https://github.com/indredk/praxis/pulls

Before submitting code, please ensure you have read and abide by the project's Code of Conduct and Contributing Guide.

License
This project is licensed under the MIT License. For more details, see the LICENSE file.

Acknowledgements
The creation of this library was inspired by the excellent ideas and implementations found in the open-source community. Special thanks to:

Sindre Sorhus: Whose design philosophy for libraries like p-limit served as a core inspiration.

Hughsk: Whose implementations for libraries like flat provided a valuable reference.

Google's Gemini AI: Who played an indispensable role as a collaborative partner throughout the entire design, implementation, debugging, and testing process, bringing modern programming theory into practice through a unique human-AI partnership.
