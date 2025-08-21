// src/utils/curry.ts

/**
 * 将一个函数柯里化，使其可以分步接收参数。
 * 这个实现借鉴了 Lodash 的 _.curry，支持在每次调用时传入任意数量的参数。
 *
 * @param fn - 需要被柯里化的原始函数。
 * @returns 一个新的、经过柯里化处理的函数。
 * @example
 * const add = (a, b, c) => a + b + c;
 * const curriedAdd = curry(add);
 * curriedAdd(1)(2)(3); // 6
 * curriedAdd(1, 2)(3); // 6
 * curriedAdd(1)(2, 3); // 6
 */
export function curry(fn: (...args: any[]) => any) {
  // 1. 获取原始函数的“元数”（arity），即它在定义时期望接收的参数数量。
  //    这是我们判断是否已收集到所有参数的关键依据。
  const arity = fn.length;

  /**
   * 这是一个内部的递归函数，用于创建并返回新的柯里化函数。
   * @param prevArgs - 通过闭包记住的、之前调用时已传入的参数数组。
   */
  function createCurried(prevArgs: any[]) {
    // 2. 返回一个新函数，它将接收下一次调用传入的参数。
    return function (this: any, ...newArgs: any[]) {

      // 3. 将之前记住的参数和本次新传入的参数合并。
      const allArgs = [...prevArgs, ...newArgs];

      // 4. 核心判断：
      //    如果合并后的参数数量已经达到或超过了原始函数的元数，
      //    说明所有参数都已集齐，可以执行原始函数了。
      if (allArgs.length >= arity) {
        return fn.apply(this, allArgs);
      } else {
        // 5. 如果参数还不够，则递归调用 createCurried，
        //    将当前收集到的所有参数 (allArgs) 传入，
        //    然后返回一个“等待接收更多参数”的、更新过的柯里化函数。
        return createCurried(allArgs);
      }
    };
  }

  // 6. 启动柯里化过程，返回第一个包装函数，它此时还没有收集到任何参数。
  return createCurried([]);
}