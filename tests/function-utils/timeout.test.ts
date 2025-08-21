// tests/withTimeout.test.ts

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
// 确保从您的工具函数文件中正确导入
import { withTimeout, TimeoutError } from '../../src/utils/function-utils/timeout';

describe('withTimeout 高阶函数', () => {

  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  // =================================================================
  // 场景 1: 成功场景 (Success Scenarios)
  // =================================================================
  it('当操作在超时前完成时，应正常 resolve (should resolve successfully when the operation finishes before timeout)', async () => {
    const fastOperation = vi.fn(async () => {
      await new Promise(resolve => setTimeout(resolve, 50));
      return 'Success';
    });

    const timedOperation = withTimeout(fastOperation, 100);
    const promise = timedOperation();

    await vi.advanceTimersByTimeAsync(50);

    await expect(promise).resolves.toBe('Success');
  });

  // =================================================================
  // 场景 2: 超时场景 (Timeout Scenarios)
  // =================================================================
  it('当操作未在超时前完成时，应 reject 一个 TimeoutError (should reject with a TimeoutError when the operation exceeds the timeout)', async () => {
    const slowOperation = vi.fn(async () => {
      await new Promise(resolve => setTimeout(resolve, 200));
      return 'Should not resolve';
    });

    const timedOperation = withTimeout(slowOperation, 100);
    const assertionPromise = expect(timedOperation()).rejects.toThrow(TimeoutError);

    await vi.advanceTimersByTimeAsync(100);

    await assertionPromise;
  });

  it('当提供了自定义错误时，超时后应 reject 该自定义错误 (should reject with the custom error on timeout if provided)', async () => {
    const slowOperation = vi.fn(async () => {
      await new Promise(resolve => setTimeout(resolve, 200));
    });

    const customError = new Error('请求数据库超时！');
    const timedOperation = withTimeout(slowOperation, 100, customError);

    const assertionPromise = expect(timedOperation()).rejects.toBe(customError);
    await vi.advanceTimersByTimeAsync(100);
    await assertionPromise;
  });

  // =================================================================
  // 场景 3: 原始函数自身失败场景 (Original Function Rejection Scenarios)
  // =================================================================

  // ***** 这是被修复的测试用例 *****
  it('当原始函数在超时前就 reject 时，应 reject 原始错误 (should reject with the original error if the function fails before timeout)', async () => {
    const originalError = new Error('API Error');
    const failingOperation = vi.fn(async () => {
      await new Promise(resolve => setTimeout(resolve, 50));
      throw originalError;
    });

    const timedOperation = withTimeout(failingOperation, 100);

    // 修复逻辑：将调用、快进时间、和断言清晰地串联起来
    // 之前的问题是重复调用 timedOperation 但没有重复快进时间
    const assertionPromise = expect(timedOperation()).rejects.toBe(originalError);
    await vi.advanceTimersByTimeAsync(50);
    await assertionPromise;

    // 我们可以额外验证它不是一个 TimeoutError
    const assertionPromise2 = expect(timedOperation()).rejects.not.toBeInstanceOf(TimeoutError);
    await vi.advanceTimersByTimeAsync(50); // 必须为这次新的调用再次快进时间
    await assertionPromise2;
  });

  // ***** 这是新增的完善用例 *****
  it('当原始函数同步抛出错误时，应立即 reject (should reject immediately if the original function throws synchronously)', async () => {
    const syncError = new Error('Invalid arguments');
    // 注意：这是一个同步函数，不是 async
    const syncThrowOperation = vi.fn(() => {
      throw syncError;
    });

    // withTimeout 应该能处理非 Promise 的函数，并捕获其同步错误
    // @ts-ignore - a b c
    const timedOperation = withTimeout(syncThrowOperation, 100);

    // 断言 Promise 会立即 reject，无需快进时间
    await expect(timedOperation()).rejects.toBe(syncError);
  });


  // =================================================================
  // 场景 4: 参数与 `this` 上下文 (Arguments and `this` Context)
  // =================================================================

  // ***** 这是被修复的第二个测试用例 (通过简化第一个修复) *****
  it('应将所有参数和 `this` 上下文正确地传递给原始函数 (should forward all arguments and `this` context to the original function)', async () => {
    const mockApiClient = {
      id: 'client-123',
      fetch: vi.fn(async function (this: { id: string }, path: string, options: object) {
        await new Promise(resolve => setTimeout(resolve, 50));
        return `Data from ${path} for client ${this.id} with options ${JSON.stringify(options)}`;
      }),
    };

    const timedFetch = withTimeout(
      mockApiClient.fetch.bind(mockApiClient),
      100
    );

    const pathArg = '/users';
    const optionsArg = { method: 'GET' };

    const promise = timedFetch(pathArg, optionsArg);
    await vi.advanceTimersByTimeAsync(50);

    const result = await promise;

    expect(mockApiClient.fetch).toHaveBeenCalledTimes(1);
    expect(mockApiClient.fetch.mock.contexts[0]).toBe(mockApiClient);
    expect(mockApiClient.fetch).toHaveBeenCalledWith(pathArg, optionsArg);
    expect(result).toBe('Data from /users for client client-123 with options {"method":"GET"}');
  });
});