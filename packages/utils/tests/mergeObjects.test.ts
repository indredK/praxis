// tests/mergeObjects.test.ts

import { describe, it, expect } from 'vitest';
import { mergeObjects, MergeConfig } from '../src/mergeObjects';

describe('mergeObjects', () => {

  // =================================================================
  // 1. 基础合并功能 (Basic Merge Functionality)
  // =================================================================
  describe('基础合并 (Basic Merging)', () => {
    it('默认应深度合并多层嵌套对象 (should deep merge deeply nested objects by default)', () => {
      const objA = { a: 1, b: { c: 2, d: { e: 3 } }, g: [1] };
      const objB = { b: { c: 3, d: { f: 4 } }, g: [2] };
      const expected = { a: 1, b: { c: 3, d: { e: 3, f: 4 } }, g: [1, 2] };
      expect(mergeObjects(objA, objB)).toEqual(expected);
    });

    it('当 deep 为 false 时应仅合并顶层属性 (should only merge top-level properties when deep is false)', () => {
      const objA = { a: 1, b: { c: 2 } };
      const objB = { a: 2, b: { d: 3 } };
      const expected = { a: 2, b: { d: 3 } };
      expect(mergeObjects(objA, objB, { deep: false })).toEqual(expected);
    });

    it('合并时应能正确处理空对象 (should handle merging with empty objects)', () => {
      const objA = { a: 1 };
      expect(mergeObjects(objA, {})).toEqual(objA);
      expect(mergeObjects({}, objA)).toEqual(objA);
    });

    it('合并时应能正确处理 null 或 undefined (should handle merging with null or undefined root objects)', () => {
      const objA = { a: 1 };
      expect(mergeObjects(objA, null)).toBe(null);
      expect(mergeObjects(objA, undefined)).toEqual(objA);
      expect(mergeObjects(null, objA)).toEqual(objA);
    });
  });

  // =================================================================
  // 2. 数组合并策略 (Array Merge Strategy)
  // =================================================================
  describe('数组合并策略 (Array Merge Strategy)', () => {
    const arrA = [1, { id: 1 }, 3];
    const arrB = [3, { id: 2 }, 5];

    it('应使用 "union" 策略合并混合类型数组 (should correctly union arrays with mixed primitive and object values)', () => {
      // Set an object is identified by reference.
      const result = mergeObjects({ data: arrA }, { data: arrB }, { arrayMerge: 'union' });
      expect(result.data).toEqual([1, { id: 1 }, 3, { id: 2 }, 5]);
    });

    it('应能正确处理空数组 (should handle empty arrays correctly)', () => {
      expect(mergeObjects({ data: [1] }, { data: [] }, { arrayMerge: 'concat' }).data).toEqual([1]);
      expect(mergeObjects({ data: [] }, { data: [1] }, { arrayMerge: 'union' }).data).toEqual([1]);
      expect(mergeObjects({ data: [1] }, { data: [] }, { arrayMerge: 'intersection' }).data).toEqual([]);
    });
  });

  // =================================================================
  // 3. 自定义合并策略 (Custom Merge Strategy)
  // =================================================================
  describe('自定义合并策略 (Custom Merge Strategy)', () => {
    it('应对深层嵌套路径应用策略 (should apply strategy to a deeply nested path)', () => {
      const objA = { config: { user: { retries: 3 } } };
      const objB = { config: { user: { retries: 5 } } };
      const config: MergeConfig = { strategy: { 'config.user.retries': 'max' } };
      expect(mergeObjects(objA, objB, config).config.user.retries).toBe(5);
    });

    it('应能用自定义函数合并对象 (should use a custom function to merge objects)', () => {
      const objA = { data: { count: 1, items: ['a'] } };
      const objB = { data: { count: 2, items: ['b'] } };
      const config: MergeConfig = {
        strategy: {
          'data': (a, b) => ({
            count: a.count + b.count,
            items: [...a.items, ...b.items]
          })
        }
      };
      const expected = { count: 3, items: ['a', 'b'] };
      expect(mergeObjects(objA, objB, config).data).toEqual(expected);
    });
  });

  // =================================================================
  // 4. 键/路径过滤 (Key/Path Filtering)
  // =================================================================
  describe('键/路径过滤 (Key/Path Filtering)', () => {
    const objA = { user: { name: 'A', details: { age: 30, city: 'LA' } }, status: 'active' };
    const objB = { user: { name: 'B', details: { city: 'NY' } }, status: 'inactive', id: 123 };

    it('应排除指定的深层嵌套路径 (should exclude a nested path)', () => {
      const config: MergeConfig = { exclude: ['user.details.city'] };
      const expected = { user: { name: 'B', details: { age: 30, city: 'LA' } }, status: 'inactive', id: 123 };
      expect(mergeObjects(objA, objB, config)).toEqual(expected);
    });

  });

  // =================================================================
  // 5. 高级行为与边界情况 (Advanced Behaviors & Edge Cases)
  // =================================================================
  describe('高级行为与边界情况 (Advanced Behaviors & Edge Cases)', () => {
    it('应正确处理 nullBehavior 的 "default" 模式 (should handle "default" nullBehavior correctly)', () => {
      const objA = { a: 1, b: undefined };
      const objB = { a: null, b: null };
      const config: MergeConfig = { nullBehavior: 'default' };
      // a 应该保持 1, b 应该变成 null
      expect(mergeObjects(objA, objB, config)).toEqual({ a: 1, b: null });
    });

    it('应在深层嵌套中处理类型冲突 (should handle type conflicts in nested objects)', () => {
      const objA = { data: { value: 100 } };
      const objB = { data: { value: { amount: 100 } } };
      const config: MergeConfig = { typeConflict: 'error' };
      expect(() => mergeObjects(objA, objB, config)).toThrow('Type conflict at data.value');
    });

    it('preMerge 钩子应在所有合并逻辑之前执行 (preMerge hook should execute before any merge logic)', () => {
      const objA = { values: [1] };
      const objB = { values: [2] };
      const config: MergeConfig = {
        preMerge: (obj) => ({ ...obj, count: obj.values.length }),
        strategy: { 'count': 'max' }
      };
      // preMerge后: a={values:[1], count:1}, b={values:[2], count:1}
      // 合并后: values:[1,2], count:1
      const expected = { values: [1, 2], count: 1 };
      expect(mergeObjects(objA, objB, config)).toEqual(expected);
    });

    it('postMerge 钩子应在所有合并逻辑之后执行 (postMerge hook should execute after all merge logic)', () => {
      const objA = { a: 1 };
      const objB = { b: 2 };
      const config: MergeConfig = {
        postMerge: (obj) => {
          const { a, b, ...rest } = obj;
          return { ...rest, sum: a + b };
        }
      };
      expect(mergeObjects(objA, objB, config)).toEqual({ sum: 3 });
    });

    it('条件合并应能根据路径决定是否合并 (condition should prevent merge based on path)', () => {
      const objA = { meta: { version: 1 }, data: { value: 'a' } };
      const objB = { meta: { version: 2 }, data: { value: 'b' } };
      const config: MergeConfig = {
        condition: (key, valA, valB, path) => path.join('.') !== 'meta.version'
      };
      // meta.version 不应合并，data.value 应该合并
      const expected = { meta: { version: 1 }, data: { value: 'b' } };
      expect(mergeObjects(objA, objB, config)).toEqual(expected);
    });

    it('应忽略 Symbol 类型的键 (should ignore symbol keys)', () => {
      const sym = Symbol('id');
      const objA = { a: 1, [sym]: 'A' };
      const objB = { a: 2, [sym]: 'B' };
      const expected = { a: 2 };
      // Object.keys an new Set() do not include symbol properties
      expect(mergeObjects(objA, objB)).toEqual(expected);
    });
  });

  // =================================================================
  // 6. 多功能组合测试 (Interaction Tests)
  // =================================================================
  describe('多功能组合测试 (Interaction Tests)', () => {
    it('exclude 应优先于 strategy (exclude should take precedence over strategy)', () => {
      const objA = { a: 10 };
      const objB = { a: 20 };
      const config: MergeConfig = {
        exclude: ['a'],
        strategy: { 'a': 'max' }
      };
      // a 被排除了，所以策略不应生效
      expect(mergeObjects(objA, objB, config)).toEqual({ a: 10 });
    });

    it('condition 返回 false 应优先于 strategy (condition returning false should take precedence over strategy)', () => {
      const objA = { a: 10 };
      const objB = { a: 20 };
      const config: MergeConfig = {
        condition: (key) => key !== 'a',
        strategy: { 'a': 'max' }
      };
      // 条件阻止了 a 的合并，所以策略不应生效
      expect(mergeObjects(objA, objB, config)).toEqual({ a: 10 });
    });

    it('strategy 应优先于全局 arrayMerge (strategy should take precedence over global arrayMerge)', () => {
      const objA = { data: [1, 2] };
      const objB = { data: [2, 3] };
      const config: MergeConfig = {
        arrayMerge: 'union', // 全局是 union
        strategy: { 'data': 'concat' } // 但 data 路径指定了 concat
      };
      expect(mergeObjects(objA, objB, config).data).toEqual([1, 2, 2, 3]);
    });

    it('当 schemaValidate 失败时，postMerge 不应返回结果 (postMerge result should not be returned if schemaValidate fails)', () => {
      const objA = { a: 1 };
      const objB = { b: 'two' };
      const config: MergeConfig = {
        postMerge: (obj) => ({ ...obj, processed: true }),
        schemaValidate: (obj) => typeof obj.b === 'number'
      };
      // schemaValidate 会在 postMerge 之后执行，并因为 b 不是数字而失败
      expect(() => mergeObjects(objA, objB, config)).toThrow('Schema validation failed!');
    });
  });

});