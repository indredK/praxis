// tests/promisify.test.ts

import { describe, it, expect } from 'vitest';
// 方案二需要显式导入 promisify.custom
// import { promisify } from 'util';
import { promisify } from '../../function-utils/promisify';

/**
 * 测试用例覆盖以下情况：
 * 1. 基本功能：正常回调 -> Promise resolve
 * 2. 错误回调 -> Promise reject
 * 3. 多个成功参数 -> 默认只取第一个
 * 4. 使用自定义 promisify.custom -> 自定义返回
 * 5. this 绑定是否保留
 * 6. 同步抛错 -> Promise reject
 * 7. 非函数输入 -> 抛出 TypeError
 */

describe('promisify 基本功能', () => {
  it('应当将一个正常的 error-first 回调函数转换为返回 Promise 的函数', async () => {
    function legacyAdd(a: number, b: number, cb: (err: any, result?: number) => void) {
      setTimeout(() => cb(null, a + b), 5);
    }

    const addAsync = promisify(legacyAdd);
    const sum = await addAsync(2, 3);
    expect(sum).toBe(5);
  });

  it('应当在回调返回错误时 reject', async () => {
    function legacyFail(cb: (err: any, result?: number) => void) {
      setTimeout(() => cb(new Error('出错了')), 5);
    }

    const failAsync = promisify(legacyFail);
    await expect(failAsync()).rejects.toThrow('出错了');
  });

  it('应当只解析第一个成功参数', async () => {
    function legacyMulti(cb: (err: any, a?: number, b?: number) => void) {
      setTimeout(() => cb(null, 1, 2), 5);
    }

    const multiAsync = promisify(legacyMulti);
    const result = await multiAsync();
    // Node 的行为：只取第一个成功参数
    expect(result).toBe(1);
  });
});

describe('promisify 自定义 custom', () => {
  it('应当使用 original[promisify.custom] 返回的函数', async () => {
    function legacyPair(x: number, y: number, cb: (err: any, a?: number, b?: number) => void) {
      setTimeout(() => cb(null, x, y), 5);
    }

    (legacyPair as any)[promisify.custom] = async (x: number, y: number) => ({ sum: x + y });

    const pairAsync = promisify(legacyPair);
    const obj = await pairAsync(2, 3);
    expect(obj).toEqual({ sum: 5 });
  });

  it('应当在 custom 不是函数时抛错', () => {
    function legacyDummy(cb: (err: any, result?: number) => void) {
      cb(null, 123);
    }

    (legacyDummy as any)[promisify.custom] = 123; // 非函数

    expect(() => promisify(legacyDummy)).toThrow(/must be of type Function/);
  });
});

describe('promisify this 绑定', () => {
  it('应当保留调用时的 this', async () => {
    class Calculator {
      factor = 10;
      multiply(x: number, cb: (err: any, result?: number) => void) {
        setTimeout(() => cb(null, x * this.factor), 5);
      }
    }

    const calc = new Calculator();
    calc.multiply = promisify(calc.multiply);

    const result = await (calc.multiply as any)(2);
    expect(result).toBe(20);
  });
});

describe('promisify 异常与非法输入', () => {
  it('应当在函数内部同步抛错时 reject', async () => {
    function badSync(cb: (err: any, result?: number) => void) {
      throw new Error('同步异常');
    }

    const badAsync = promisify(badSync);
    await expect(badAsync()).rejects.toThrow('同步异常');
  });

  it('应当在输入不是函数时抛出 TypeError', () => {
    expect(() => promisify(123 as any)).toThrow(TypeError);
  });
});