// src/utils/onceAsyncWithReset.ts

/**
 * 定义我们新函数的返回类型。
 * 它是一个函数，并且还带有一个 `reset` 方法。
 * 我们使用 TypeScript 的交叉类型 (&) 来表示。
 */
type ResettableAsyncFunction<T extends any[], R> =
  ((...args: T) => Promise<R>) & { reset: () => void };

/**
 * 创建一个确保异步函数只执行一次的高阶函数，并附加一个 .reset() 方法来清除缓存。
 * @param fn - 需要被包装的异步函数。
 * @returns 一个新的异步函数，其上附加了一个 .reset() 方法。
 */
export function onceAsyncWithReset<T extends any[], R>(
  fn: (...args: T) => Promise<R>
): ResettableAsyncFunction<T, R> {
  let cachedPromise: Promise<R> | null = null;

  const resettableFn = function (this: any, ...args: T): Promise<R> {
    if (!cachedPromise) {
      cachedPromise = fn.apply(this, args)
        .catch(error => {
          cachedPromise = null;
          throw error;
        });
    }
    return cachedPromise;
  };

  const reset = () => {
    cachedPromise = null;
  };

  // *** 关键修复 ***
  // 使用 Object.assign 来创建一个 TypeScript 能够正确推断类型的对象。
  // 它能理解我们返回的是一个“函数”与一个“带有 reset 方法的对象”的组合体。
  return Object.assign(resettableFn, { reset });
}