// tests/curry.test.ts

import { describe, it, expect } from 'vitest';
import { curry } from '../../src/utils/function-utils/curry';

describe('curry (柯里化函数)', () => {

  // =================================================================
  // 基础功能测试 (Basic Functionality Tests)
  // =================================================================

  describe('对于一个元数为 3 的函数 (For a function with arity 3)', () => {
    const sum = (a: number, b: number, c: number): number => a + b + c;
    const curriedSum = curry(sum);

    it('应在每次调用传入一个参数时正确工作 (should work with one argument at a time)', () => {
      expect(curriedSum(1)(2)(3)).toBe(6);
    });

    it('应在混合传递参数时正确工作 (should work with mixed argument counts)', () => {
      expect(curriedSum(1, 2)(3)).toBe(6);
      expect(curriedSum(1)(2, 3)).toBe(6);
    });

    it('应在一次性传递所有参数时正确工作 (should work when all arguments are passed at once)', () => {
      expect(curriedSum(1, 2, 3)).toBe(6);
    });

    it('在参数不足时应返回一个新函数 (should return a new function when not enough arguments are provided)', () => {
      const fn1 = curriedSum(1);
      expect(typeof fn1).toBe('function');

      const fn2 = fn1(2);
      expect(typeof fn2).toBe('function');

      // 确认返回的不是同一个函数实例
      expect(fn1).not.toBe(fn2);

      const result = fn2(3);
      expect(result).toBe(6);
    });
  });

  describe('对于一个元数为 2 的函数 (For a function with arity 2)', () => {
    const multiply = (a: number, b: number): number => a * b;
    const curriedMultiply = curry(multiply);

    it('应能正确创建偏函数 (should create partial applications correctly)', () => {
      const double = curriedMultiply(2); // 创建一个“乘以2”的新函数
      const triple = curriedMultiply(3); // 创建一个“乘以3”的新函数

      expect(double(5)).toBe(10);
      expect(double(10)).toBe(20);

      expect(triple(5)).toBe(15);
      expect(triple(10)).toBe(30);
    });
  });

  // =================================================================
  // 边界情况与高级特性 (Edge Cases & Advanced Features)
  // =================================================================

  describe('边界情况 (Edge Cases)', () => {
    it('应能正确处理元数为 0 的函数 (should handle functions with zero arity)', () => {
      const fn = () => 'hello';
      const curriedFn = curry(fn);

      // fn.length 是 0，所以第一次调用就应该执行
      expect(curriedFn()).toBe('hello');
    });

    it('当传入的参数多于元数时，应立即执行并传递所有参数 (should execute immediately with all arguments if more than arity are provided)', () => {
      // a b c .length 是 2
      const addTwo = (a: number, b: number) => a + b;
      const curriedAdd = curry(addTwo);

      // JavaScript 函数默认会忽略多余的参数
      // @ts-ignore - a b c
      expect(curriedAdd(10, 2, 99, 100)).toBe(12);
    });
  });

  describe('`this` 上下文 (this Context)', () => {

    // ***** 这是被修复的测试用例 *****
    it('默认情况下不应绑定 `this` 上下文 (should NOT bind `this` context by default)', () => {
      const context = {
        multiplier: 10,
        calculate(a: number, b: number) {
          return (a + b) * this.multiplier;
        },
      };

      const curriedCalc = curry(context.calculate);

      // 修复方案：
      // 我们不再尝试获取返回值，因为函数调用会直接失败。
      // 我们用一个函数包裹器来调用 curriedCalc(2)(3)，
      // 并断言这个调用行为会“抛出”一个错误。
      // 这精确地描述了当 `this` 上下文丢失时发生的真实情况。
      expect(() => {
        curriedCalc(2)(3);
      }).toThrow(TypeError); // 我们可以断言它会抛出 TypeError

      // 或者更具体地断言错误信息
      expect(() => {
        curriedCalc(2)(3);
      }).toThrow('Cannot read properties of undefined');
    });

    it('应在手动绑定 `this` 后正确工作 (should work correctly after `this` is bound manually)', () => {
      const context = {
        multiplier: 10,
        calculate(a: number, b: number) {
          return (a + b) * this.multiplier;
        },
      };

      const boundCalculate = context.calculate.bind(context);
      const curriedCalc = curry(boundCalculate);

      const result = curriedCalc(2)(3);

      expect(result).toBe(50);
    });
  });
});