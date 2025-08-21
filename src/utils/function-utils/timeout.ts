// src/utils/withTimeout.ts

/**
 * 自定义超时错误类，方便调用方通过 `instanceof` 来精确判断错误类型。
 */
export class TimeoutError extends Error {
  constructor(message = 'Operation timed out') {
    super(message);
    this.name = 'TimeoutError';
  }
}

/**
 * (辅助函数) 为一个 Promise 增加超时功能。
 */
function timeout<T>(
  promise: Promise<T>,
  ms: number,
  customError?: Error
): Promise<T> {
  const timeoutPromise = new Promise<never>((_, reject) => {
    setTimeout(() => {
      reject(customError || new TimeoutError(`Operation timed out after ${ms}ms`));
    }, ms);
  });

  return Promise.race([
    promise,
    timeoutPromise,
  ]);
}


/**
 * 一个高阶函数，接收一个异步函数 (fn) 和一个超时时间 (ms)，
 * 返回一个带有超时功能的新异步函数。
 * * 这个健壮的版本能够处理原始函数 fn 的同步抛错和异步 rejection。
 */
export function withTimeout<T extends any[], R>(
  fn: (...args: T) => Promise<R>,
  ms: number,
  customError?: Error
): (...args: T) => Promise<R> {

  return function (this: any, ...args: T): Promise<R> {
    try {
      // 步骤 1: 调用原始函数。
      // fn.apply(this, args) 可能会返回一个 Promise (正常情况)，
      // 也可能直接同步地抛出一个错误 (边界情况)。
      const originalPromise = fn.apply(this, args);

      // 步骤 2: 将返回的 Promise（如果成功返回）与我们的超时逻辑进行赛跑。
      return timeout(originalPromise, ms, customError);

    } catch (error) {
      // 步骤 3: 如果 fn.apply 同步地抛出了错误，在这里捕获它。
      // 然后，我们返回一个立即被 reject 的 Promise，并将原始错误传递出去。
      // 这样就将同步错误转换为了异步错误，符合函数的期望行为。
      return Promise.reject(error);
    }
  };
}