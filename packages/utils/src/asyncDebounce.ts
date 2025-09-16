// src/utils/asyncDebounce.ts

/**
 * 创建一个异步防抖函数。
 * 当调用返回的函数时，如果上一次的异步操作尚未完成，则本次调用将被忽略。
 * 这对于防止用户重复点击按钮，导致同一时间发起多个相同的网络请求非常有用。
 * * @param fn 需要进行异步防抖的函数，该函数必须返回一个 Promise。
 * @returns 一个新的、经过异步防抖处理的函数。
 * @template T - 原函数的参数类型数组。
 * @template R - 原函数返回的 Promise 的 Resolve 类型。
 */
export function asyncDebounce<T extends any[], R>(
  fn: (...args: T) => Promise<R>
): (...args: T) => Promise<R | undefined> {
  // 使用闭包来维护一个“执行中”的状态标志
  let isExecuting = false;

  return function (this: any, ...args: T): Promise<R | undefined> {
    // 如果当前已有操作在执行中，则立即返回一个 resolved 的 undefined Promise，不做任何事
    if (isExecuting) {
      console.warn('操作正在进行中，本次触发已被防抖。');
      return Promise.resolve(undefined);
    }

    // 标记为“执行中”
    isExecuting = true;

    // 调用原始函数，并确保在操作完成后（无论成功还是失败）重置标志
    return fn.apply(this, args).finally(() => {
      // 操作完成，重置标志，允许下一次调用
      isExecuting = false;
    });
  };
}