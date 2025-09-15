// tests/onceAsyncWithReset.test.ts

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
// 确保从您的工具函数文件中正确导入
import { onceAsyncWithReset } from '../../function-utils/onceAsyncWithReset';

describe('onceAsyncWithReset (带重置功能的异步单例函数)', () => {

  // 在每个测试用例运行前，启用模拟计时器
  beforeEach(() => {
    vi.useFakeTimers();
  });

  // 在每个测试用例运行后，恢复真实的计时器
  afterEach(() => {
    vi.useRealTimers();
  });

  // =================================================================
  // 1. 基础的 "once" 功能测试 (Basic "once" Functionality)
  // =================================================================
  describe('基础功能 (Basic "once" functionality)', () => {
    it('应只执行一次原始函数，并为所有并发调用返回相同的结果 (should execute the original function only once and return the same result for all concurrent calls)', async () => {
      const mockApiCall = vi.fn(async () => {
        await new Promise(resolve => setTimeout(resolve, 1000));
        return { data: 'shared_data' };
      });

      const getSharedData = onceAsyncWithReset(mockApiCall);

      const promise1 = getSharedData();
      const promise2 = getSharedData();

      // 立即断言：原始函数只被调用了一次
      expect(mockApiCall).toHaveBeenCalledTimes(1);

      await vi.runAllTimersAsync();

      const [result1, result2] = await Promise.all([promise1, promise2]);

      // 最终断言：原始函数总共仍然只执行了一次
      expect(mockApiCall).toHaveBeenCalledTimes(1);
      // 并且两次调用都收到了相同的结果
      expect(result1).toEqual({ data: 'shared_data' });
      expect(result2).toBe(result1); // 结果应该是同一个对象实例
    });

    it('后续调用应返回第一次调用时缓存的同一个 Promise 实例 (should return the same cached promise instance for subsequent calls)', () => {
      const mockApiCall = vi.fn(async () => { });
      const getPromise = onceAsyncWithReset(mockApiCall);

      const promise1 = getPromise();
      const promise2 = getPromise();

      // 断言两个返回的 Promise 是严格相等的
      expect(promise1).toBe(promise2);
    });
  });

  // =================================================================
  // 2. `.reset()` 方法功能测试 ('.reset()' Method Functionality)
  // =================================================================
  describe('`.reset()` 方法功能 (.reset() Method Functionality)', () => {
    it('在成功后调用 .reset()，应允许下一次调用重新执行原始函数 (calling .reset() after success should allow the next call to re-execute)', async () => {
      let counter = 0;
      const mockApiCall = vi.fn(async () => {
        counter++;
        await new Promise(resolve => setTimeout(resolve, 1000));
        return `Call #${counter}`;
      });

      const getCounter = onceAsyncWithReset(mockApiCall);

      // 第一次调用
      const promise1 = getCounter();
      await vi.runAllTimersAsync();
      await expect(promise1).resolves.toBe('Call #1');
      expect(mockApiCall).toHaveBeenCalledTimes(1);

      // 第二次调用（无 reset），应该使用缓存
      const promise2 = getCounter();
      await expect(promise2).resolves.toBe('Call #1');
      expect(mockApiCall).toHaveBeenCalledTimes(1); // 次数未增加

      // *** 重置 ***
      getCounter.reset();
      console.log('Cache has been reset.');

      // 重置后第三次调用，应该重新执行
      const promise3 = getCounter();
      expect(mockApiCall).toHaveBeenCalledTimes(2); // 次数增加！
      await vi.runAllTimersAsync();
      await expect(promise3).resolves.toBe('Call #2');
    });

    it('在 Promise 完成前调用 .reset()，不应影响正在进行的 Promise (calling .reset() before a promise completes should not affect the ongoing promise)', async () => {
      const mockApiCall = vi.fn(async () => {
        await new Promise(resolve => setTimeout(resolve, 1000));
        return 'Original';
      });

      const getPromise = onceAsyncWithReset(mockApiCall);

      const promise1 = getPromise();

      // 在 promise1 完成前就调用 reset
      getPromise.reset();

      // 快进时间，让原始的 promise1 完成
      await vi.runAllTimersAsync();

      // 断言原始的 promise1 仍然按预期完成
      await expect(promise1).resolves.toBe('Original');
      expect(mockApiCall).toHaveBeenCalledTimes(1);

      // 因为已经重置，下一次调用会重新执行
      getPromise();
      expect(mockApiCall).toHaveBeenCalledTimes(2);
    });
  });

  // =================================================================
  // 3. 错误处理与重试 (Error Handling & Retry)
  // =================================================================
  describe('错误处理与重试 (Error Handling & Retry)', () => {
    it('当原始函数 reject 时，缓存应自动清除，允许下一次调用重试 (should automatically reset on rejection, allowing a retry)', async () => {
      let shouldFail = true;
      const mockApiCall = vi.fn(async () => {
        await new Promise(resolve => setTimeout(resolve, 1000));
        if (shouldFail) {
          shouldFail = false; // 改变状态，使得下一次调用会成功
          throw new Error('Failure');
        }
        return 'Success after retry';
      });

      const getWithRetry = onceAsyncWithReset(mockApiCall);

      // 第一次调用，预期会失败
      const rejectionPromise = expect(getWithRetry()).rejects.toThrow('Failure');
      await vi.runAllTimersAsync();
      await rejectionPromise;
      expect(mockApiCall).toHaveBeenCalledTimes(1);

      // 第二次调用，因为上次失败了，应该会重新执行
      const successPromise = expect(getWithRetry()).resolves.toBe('Success after retry');
      expect(mockApiCall).toHaveBeenCalledTimes(2); // 确认重新执行
      await vi.runAllTimersAsync();
      await successPromise;
    });
  });

  // =================================================================
  // 4. `this` 上下文与参数 (this Context & Arguments)
  // =================================================================
  describe('`this` 上下文与参数 (`this` Context & Arguments)', () => {
    it('重置后，新的调用应使用新的参数和 `this` 上下文 (should use new arguments and `this` context for the call after a reset)', async () => {
      const mockService = {
        name: 'Service',
        fetch: vi.fn(async function (this: { name: string }, id: number) {
          await new Promise(resolve => setTimeout(resolve, 50));
          return `${this.name} fetched data for ID ${id}`;
        }),
      };

      const otherContext = { name: 'OtherService' };

      const getFromService = onceAsyncWithReset(mockService.fetch);

      // 第一次调用，绑定到 mockService
      const promise1 = getFromService.call(mockService, 1);
      await vi.runAllTimersAsync();
      await expect(promise1).resolves.toBe('Service fetched data for ID 1');
      expect(mockService.fetch).toHaveBeenCalledTimes(1);
      expect(mockService.fetch).toHaveBeenCalledWith(1);
      expect(mockService.fetch.mock.contexts[0]).toBe(mockService);

      // *** 重置 ***
      getFromService.reset();

      // 第二次调用，绑定到 otherContext 并使用不同参数
      const promise2 = getFromService.call(otherContext, 99);
      await vi.runAllTimersAsync();
      await expect(promise2).resolves.toBe('OtherService fetched data for ID 99');

      // 确认原始函数被再次调用
      expect(mockService.fetch).toHaveBeenCalledTimes(2);
      // 确认新的调用使用了新的参数和 `this`
      expect(mockService.fetch).toHaveBeenLastCalledWith(99);
      expect(mockService.fetch.mock.contexts[1]).toBe(otherContext);
    });
  });
});