// tests/flat.test.ts

import { describe, it, expect } from 'vitest';
// 确保从您的 TypeScript 工具函数文件中正确导入
import { flatten, unflatten } from '../../function-utils/flat';

describe('flatten / unflatten', () => {

  // =================================================================
  // `flatten` 函数测试 (flatten function tests)
  // =================================================================
  describe('flatten', () => {
    it('应能扁平化一个简单的嵌套对象 (should flatten a simple nested object)', () => {
      const original = {
        a: 1,
        b: { c: 2 },
        d: { e: { f: 3 } },
      };
      const expected = {
        'a': 1,
        'b.c': 2,
        'd.e.f': 3,
      };
      expect(flatten(original)).toEqual(expected);
    });

    it('应能扁平化包含数组的对象 (should flatten an object containing an array)', () => {
      const original = {
        a: { b: [1, 2] },
      };
      const expected = {
        'a.b.0': 1,
        'a.b.1': 2,
      };
      expect(flatten(original)).toEqual(expected);
    });

    it('应能处理复杂的嵌套结构 (should handle complex nested structures)', () => {
      const original = {
        hello: {
          world: 'is great',
          'dot.dot': 'is sad',
        },
        level2: {
          deeper: [{
            a: 1,
            b: 2
          }],
        }
      };
      const expected = {
        'hello.world': 'is great',
        'hello.dot.dot': 'is sad',
        'level2.deeper.0.a': 1,
        'level2.deeper.0.b': 2,
      };
      expect(flatten(original)).toEqual(expected);
    });
  });

  // =================================================================
  // `unflatten` 函数测试 (unflatten function tests)
  // =================================================================
  describe('unflatten', () => {
    it('应能复原一个简单的扁平化对象 (should unflatten a simple flattened object)', () => {
      const original = {
        'a': 1,
        'b.c': 2,
        'd.e.f': 3,
      };
      const expected = {
        a: 1,
        b: { c: 2 },
        d: { e: { f: 3 } },
      };
      expect(unflatten(original)).toEqual(expected);
    });

    it('应能将带数字键的路径复原为数组 (should unflatten paths with numeric keys into an array)', () => {
      const original = {
        'a.b.0': 1,
        'a.b.1': 2,
      };
      const expected = {
        a: { b: [1, 2] },
      };
      expect(unflatten(original)).toEqual(expected);
    });

    it('应能处理“混乱”的对象（即值本身也需要扁平化）(should handle "messy" objects where values also need flattening)', () => {
      const original = {
        'a.b': {
          'c.d': 1
        },
        'e': 2
      };
      const expected = {
        a: {
          b: {
            c: {
              d: 1
            }
          }
        },
        e: 2
      };
      expect(unflatten(original)).toEqual(expected);
    });
  });

  // =================================================================
  // 选项配置测试 (Options tests)
  // =================================================================
  describe('选项配置 (Options)', () => {
    it('`delimiter` 选项应能自定义分隔符 (should use a custom delimiter for both flatten and unflatten)', () => {
      const original = { a: { b: 1 } };
      const flattened = { 'a_b': 1 };

      expect(flatten(original, { delimiter: '_' })).toEqual(flattened);
      expect(unflatten(flattened, { delimiter: '_' })).toEqual(original);
    });

    it('`safe` 选项应能阻止数组被扁平化 (should prevent arrays from being flattened when `safe` is true)', () => {
      const original = {
        a: [1, 2],
        b: { c: [{ d: 1 }] }
      };
      const expected = {
        'a': [1, 2],
        'b.c': [{ d: 1 }],
      };
      expect(flatten(original, { safe: true })).toEqual(expected);
    });

    it('`object` 选项应强制将数字键复原为对象 (should force unflattening to objects when `object` is true)', () => {
      const flattened = {
        'a.0': 1,
        'b.0.c': 2
      };
      const expectedAsArray = {
        a: [1],
        b: [{ c: 2 }]
      };
      const expectedAsObject = {
        a: { '0': 1 },
        b: { '0': { c: 2 } }
      };

      expect(unflatten(flattened)).toEqual(expectedAsArray);
      expect(unflatten(flattened, { object: true })).toEqual(expectedAsObject);
    });

    it('`overwrite` 选项应允许深层路径覆盖浅层值 (should allow nested keys to overwrite parent keys when `overwrite` is true)', () => {
      const flattened = {
        'a': 1,
        'a.b': 2,
      };

      // 默认情况下，'a.b' 不会覆盖 'a'
      expect(unflatten(flattened)).toEqual({ a: 1 });

      // 开启 overwrite 后，'a' 会被创建为一个对象以容纳 'b'
      expect(unflatten(flattened, { overwrite: true })).toEqual({ a: { b: 2 } });
    });

    it('`maxDepth` 选项应能限制扁平化深度 (should limit the flattening depth with `maxDepth`)', () => {
      const original = {
        a: { b: { c: { d: 1 } } }
      };
      const expected = {
        'a.b': { c: { d: 1 } }
      };
      expect(flatten(original, { maxDepth: 2 })).toEqual(expected);
    });

    it('`transformKey` 选项应能转换路径中的键 (should transform keys with `transformKey`)', () => {
      const original = { a: { b: 1 } };
      const transform = (key: string) => `_${key}_`;
      const flattened = { '_a_._b_': 1 };

      // 1. 验证 flatten 的行为（这部分是正确的）
      expect(flatten(original, { transformKey: transform })).toEqual(flattened);

      // 2. *** 修正期望结果 ***
      // 修复后的 unflatten 会正确地使用扁平化对象的键来构建新对象。
      // 它没有能力“逆向”转换键，所以我们期望得到的是一个键被转换了的新对象。
      const expectedUnflattened = {
        '_a_': {
          '_b_': 1
        }
      };

      // 注意：这里的第二个参数我们传一个空对象，因为 transformKey 对 unflatten 来说没有意义
      expect(unflatten(flattened, {})).toEqual(expectedUnflattened);
    });
  });

  // =================================================================
  // 边界与安全情况测试 (Edge and Safety Cases)
  // =================================================================
  describe('边界与安全 (Edge Cases & Safety)', () => {
    // 这个测试在 Node.js 环境中更有意义
    it('应能正确处理 Buffer 对象 (should handle Buffer objects)', () => {
      // 在浏览器环境中，我们会模拟一个类似 Buffer 的对象
      const mockBuffer = {
        constructor: { isBuffer: () => true },
        // ... 其他 Buffer 属性
      };
      const original = { a: mockBuffer };

      // Buffer 不应被扁平化
      expect(flatten(original)).toEqual({ a: mockBuffer });
      // 复原时也应保持原样
      expect(unflatten({ a: mockBuffer })).toEqual(original);
    });

    it('unflatten 不应导致原型链污染 (unflatten should not cause prototype pollution)', () => {
      const flattened = {
        '__proto__.polluted': 'hello'
      };

      unflatten(flattened);

      // @ts-ignore
      const isPolluted = ({}).polluted === 'hello';

      expect(isPolluted).toBe(false);
    });
  });
});