// tests/asyncDebounce.test.ts

import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { asyncDebounce } from '../../function-utils/asyncDebounce';

// 主测试套件
describe('asyncDebounce (异步防抖函数)', () => {

  // 在每个测试用例运行前，启用模拟计时器
  beforeEach(() => {
    vi.useFakeTimers();
  });

  // 在每个测试用例运行后，恢复真实的计时器，避免影响其他测试
  afterEach(() => {
    vi.useRealTimers();
  });

  // =================================================================
  // 基础功能测试 (Basic Functionality Tests)
  // =================================================================
  it('应执行第一次调用并返回正确的结果 (should execute the first call and return the correct result)', async () => {
    // 准备一个模拟的异步函数
    const mockApiCall = vi.fn(async (arg: string) => {
      await new Promise(resolve => setTimeout(resolve, 1000));
      return `Data for ${arg}`;
    });

    const debouncedApiCall = asyncDebounce(mockApiCall);

    const promise = debouncedApiCall('query1');

    // 立即断言：原始函数已被调用一次
    expect(mockApiCall).toHaveBeenCalledTimes(1);
    expect(mockApiCall).toHaveBeenCalledWith('query1');

    // 快进时间，让 Promise 完成
    await vi.runAllTimersAsync();

    // 断言 Promise resolve 的值是正确的
    await expect(promise).resolves.toBe('Data for query1');
  });

  // =================================================================
  // 核心防抖逻辑测试 (Core Debouncing Logic Tests)
  // =================================================================
  it('在第一次调用完成前，后续的调用应被忽略 (should ignore subsequent calls before the first one completes)', async () => {
    const mockApiCall = vi.fn(async () => {
      await new Promise(resolve => setTimeout(resolve, 1000));
      return 'Success';
    });

    const debouncedApiCall = asyncDebounce(mockApiCall);

    // 连续快速调用三次
    const promise1 = debouncedApiCall();
    const promise2 = debouncedApiCall();
    const promise3 = debouncedApiCall();

    // 立即断言：尽管调用了三次，但原始函数只执行了一次
    expect(mockApiCall).toHaveBeenCalledTimes(1);

    // 快进时间
    await vi.runAllTimersAsync();

    // 等待所有 Promise 完成
    const [result1, result2, result3] = await Promise.all([promise1, promise2, promise3]);

    // 最终断言：原始函数总共仍然只执行了一次
    expect(mockApiCall).toHaveBeenCalledTimes(1);

    // 验证返回值：只有第一个调用有结果，被防抖的调用返回 undefined
    expect(result1).toBe('Success');
    expect(result2).toBeUndefined();
    expect(result3).toBeUndefined();
  });

  it('在第一次调用完成后，应能成功发起下一次调用 (should allow a new call after the previous one has completed)', async () => {
    const mockApiCall = vi.fn(async () => {
      await new Promise(resolve => setTimeout(resolve, 1000));
      return 'Completed';
    });

    const debouncedApiCall = asyncDebounce(mockApiCall);

    // 第一次调用
    const promise1 = debouncedApiCall();
    await vi.runAllTimersAsync();
    await promise1;

    // 断言第一次调用已完成
    expect(mockApiCall).toHaveBeenCalledTimes(1);

    // 第二次调用
    const promise2 = debouncedApiCall();

    // 断言第二次调用也成功触发了
    expect(mockApiCall).toHaveBeenCalledTimes(2);

    await vi.runAllTimersAsync();
    const result2 = await promise2;

    // 断言第二次调用的结果
    expect(result2).toBe('Completed');
  });

  // =================================================================
  // 错误处理与状态恢复测试 (Error Handling & State Recovery Tests)
  // =================================================================
  it('如果函数抛出错误，也应释放锁定状态，允许下一次调用 (should release the lock even if the function rejects)', async () => {
    let callCount = 0;
    const mockApiCall = vi.fn(async () => {
      callCount++;
      await new Promise(resolve => setTimeout(resolve, 1000));
      if (callCount === 1) {
        throw new Error('API Failed');
      }
      return 'Success on second try';
    });

    const debouncedApiCall = asyncDebounce(mockApiCall);

    // *** 最终修复 ***
    // 步骤 1: 调用函数并立即将其包装在 expect().rejects 中。
    // 这会返回一个新的 "断言 Promise"，它已经准备好处理即将到aien rejection。
    const assertionPromise = expect(debouncedApiCall()).rejects.toThrow('API Failed');

    // 步骤 2: 快进计时器，这会真正触发原始 Promise 的 rejection。
    await vi.runAllTimersAsync();

    // 步骤 3: 等待断言 Promise 完成。
    // 因为原始 Promise 确实按预期 reject 了，所以断言会成功，这个 Promise 会 resolve。
    await assertionPromise;

    // 断言第一次调用确实发生了
    expect(mockApiCall).toHaveBeenCalledTimes(1);

    // 现在，确认锁定已释放，第二次调用可以继续
    const promise2 = debouncedApiCall();
    expect(mockApiCall).toHaveBeenCalledTimes(2);

    await vi.runAllTimersAsync();
    await expect(promise2).resolves.toBe('Success on second try');
  });

  // =================================================================
  // 上下文与参数传递测试 (Context & Argument Forwarding Tests)
  // =================================================================
  it('应正确传递参数和 `this` 上下文 (should forward arguments and `this` context correctly)', async () => {
    const context = {
      id: 'test-context',
      // 使用 vi.fn 包装一个 function 声明，以便访问 `this`
      method: vi.fn(async function (this: { id: string }, arg1: number, arg2: string) {
        await new Promise(resolve => setTimeout(resolve, 1000));
        return {
          thisId: this.id,
          args: [arg1, arg2],
        };
      }),
    };

    const debouncedMethod = asyncDebounce(context.method);

    // 使用 .call 来绑定 this 和传递参数
    const promise = debouncedMethod.call(context, 123, 'hello');

    await vi.runAllTimersAsync();

    const result = await promise;

    // 断言原始方法被调用时，`this` 指向正确的上下文
    expect(context.method.mock.contexts[0]).toBe(context);

    // 断言参数被正确传递
    expect(context.method).toHaveBeenCalledWith(123, 'hello');

    // 断言最终结果也符合预期
    expect(result).toEqual({
      thisId: 'test-context',
      args: [123, 'hello'],
    });
  });
});