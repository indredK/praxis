// tests/pLimit.vitest.test.ts

import { describe, it, expect } from 'vitest';
import { AsyncLocalStorage } from 'node:async_hooks';

// 假设 pLimit 函数位于上一级目录的 index.ts (或 .js) 文件中
import pLimit, { limitFunction } from '../../src/utils/function-utils/pLimit';


// ----------------- 轻量替代实现（零依赖） -----------------

/** delay(ms): 返回一个在 ms 毫秒后 resolve 的 Promise */
const delay = (ms: number) => new Promise<void>(resolve => setTimeout(resolve, ms));

/** inRange(value, {start, end}): 判断 value 是否在闭区间 [start, end] 内 */
function inRange(value: number, opts: { start: number; end: number }) {
  return value >= opts.start && value <= opts.end;
}

/** timeSpan(): 返回一个 end() 函数，调用 end() 得到自 timeSpan() 被调用后经过的毫秒数 */
function timeSpan() {
  const start = Date.now();
  return () => Date.now() - start;
}

/**
 * randomInt(min, max?)
 * - 如果只传一个参数，则视为 0..min
 * - 否则返回 [min, max] 包含边界的随机整数
 */
function randomInt(min: number, max?: number) {
  if (max === undefined) {
    max = min;
    min = 0;
  }
  const lo = Math.ceil(min);
  const hi = Math.floor(max);
  return Math.floor(Math.random() * (hi - lo + 1)) + lo;
}

// ------------------------------------------------------------

// --- 测试套件 ---

describe('pLimit', () => {

  test('concurrency: 1', async () => {
    const input: [number, number][] = [
      [10, 300],
      [20, 200],
      [30, 100],
    ];

    const end = timeSpan();
    const limit = pLimit(1);

    const mapper = ([value, ms]: [number, number]) => limit(async () => {
      await delay(ms);
      return value;
    });

    expect(await Promise.all(input.map(x => mapper(x)))).toEqual([10, 20, 30]);
    expect(inRange(end(), { start: 590, end: 650 })).toBe(true);
  });

  test('concurrency: 4', async () => {
    const concurrency = 5;
    let running = 0;

    const limit = pLimit(concurrency);

    const input = Array.from({ length: 100 }, () => limit(async () => {
      running++;
      expect(running).toBeLessThanOrEqual(concurrency);
      await delay(randomInt(30, 200));
      running--;
    }));

    await Promise.all(input);
  });

  test('propagates async execution context properly', async () => {
    const concurrency = 2;
    const limit = pLimit(concurrency);
    const store = new AsyncLocalStorage<{ id: number }>();

    const checkId = async (id: number) => {
      await Promise.resolve();
      expect(id).toBe(store.getStore()?.id);
    };

    const startContext = async (id: number) =>
      store.run({ id }, () => limit(checkId, id));

    await Promise.all(Array.from({ length: 100 }, (_, id) => startContext(id)));
  });

  test('non-promise returning function', async () => {
    const limit = pLimit(1);
    // 只要不抛就行，期望 resolve 返回 null（与原 AVA 测试语义等价）
    await expect(limit(() => null)).resolves.toBe(null);
  });

  test('continues after sync throw', async () => {
    const limit = pLimit(1);
    let ran = false;

    const promises = [
      limit(() => {
        throw new Error('err');
      }),
      limit(() => {
        ran = true;
      }),
    ];

    try {
      await Promise.all(promises);
    } catch { }
    expect(ran).toBe(true);
  });

  test('accepts additional arguments', async () => {
    const limit = pLimit(1);
    const symbol = Symbol('test');

    await limit((a: unknown) => {
      expect(a).toBe(symbol);
    }, symbol);
  });

  test('does not ignore errors', async () => {
    const limit = pLimit(1);
    const error = new Error('🦄');

    const promises = [
      limit(async () => {
        await delay(30);
      }),
      limit(async () => {
        await delay(80);
        throw error;
      }),
      limit(async () => {
        await delay(50);
      }),
    ];

    await expect(Promise.all(promises)).rejects.toBe(error);
  });

  test('runs all tasks asynchronously', async () => {
    const limit = pLimit(3);

    let value = 1;

    const one = limit(() => 1);
    const two = limit(() => value);

    expect((limit as any).activeCount ?? (limit as unknown as { activeCount: number }).activeCount).toBe(2);

    value = 2;

    const result = await Promise.all([one, two]);

    expect(result).toEqual([1, 2]);
  });

  test('activeCount and pendingCount properties', async () => {
    const limit = pLimit(5);
    expect((limit as any).activeCount ?? (limit as unknown as { activeCount: number }).activeCount).toBe(0);
    expect((limit as any).pendingCount ?? (limit as unknown as { pendingCount: number }).pendingCount).toBe(0);

    const runningPromise1 = limit(() => delay(1000));
    expect((limit as any).activeCount ?? (limit as unknown as { activeCount: number }).activeCount).toBe(1);
    expect((limit as any).pendingCount ?? (limit as unknown as { pendingCount: number }).pendingCount).toBe(0);

    await runningPromise1;
    expect((limit as any).activeCount ?? (limit as unknown as { activeCount: number }).activeCount).toBe(0);
    expect((limit as any).pendingCount ?? (limit as unknown as { pendingCount: number }).pendingCount).toBe(0);

    const immediatePromises = Array.from({ length: 5 }, () => limit(() => delay(1000)));
    const delayedPromises = Array.from({ length: 3 }, () => limit(() => delay(1000)));

    expect((limit as any).activeCount ?? (limit as unknown as { activeCount: number }).activeCount).toBe(5);
    expect((limit as any).pendingCount ?? (limit as unknown as { pendingCount: number }).pendingCount).toBe(3);

    await Promise.all(immediatePromises);
    expect((limit as any).activeCount ?? (limit as unknown as { activeCount: number }).activeCount).toBe(3);
    expect((limit as any).pendingCount ?? (limit as unknown as { pendingCount: number }).pendingCount).toBe(0);

    await Promise.all(delayedPromises);

    expect((limit as any).activeCount ?? (limit as unknown as { activeCount: number }).activeCount).toBe(0);
    expect((limit as any).pendingCount ?? (limit as unknown as { pendingCount: number }).pendingCount).toBe(0);
  });

  test('clearQueue', async () => {
    const limit = pLimit(1);

    Array.from({ length: 1 }, () => limit(() => delay(1000)));
    Array.from({ length: 3 }, () => limit(() => delay(1000)));

    await Promise.resolve();
    expect((limit as any).pendingCount ?? (limit as unknown as { pendingCount: number }).pendingCount).toBe(3);
    (limit as any).clearQueue?.();
    // 如果实现名为 clearQueue，不同实现可能是 clearQueue 或 clearQueue()
    // 上面调用尝试防止 TS 报错并当作存在方法去调用
    expect((limit as any).pendingCount ?? (limit as unknown as { pendingCount: number }).pendingCount).toBe(0);
  });

  test('map', async () => {
    const limit = pLimit(1);
    const results = await (limit as any).map?.([1, 2, 3, 4, 5, 6, 7], (input: number) => input + 1);
    expect(results).toEqual([2, 3, 4, 5, 6, 7, 8]);
  });

  test('map passes index and preserves order with concurrency', async () => {
    const limit = pLimit(3);
    const inputs = [10, 10, 10, 10, 10];

    // eslint-disable-next-line unicorn/no-array-method-this-argument
    const results = await (limit as any).map?.(inputs, async (value: number, index: number) => {
      // 模拟不同耗时以打乱完成顺序
      await delay((inputs.length - index) * 5);
      return value + index;
    });

    expect(results).toEqual([10, 11, 12, 13, 14]);
  });

  test('throws on invalid concurrency argument', () => {
    expect(() => pLimit(0 as any)).toThrow();
    expect(() => pLimit(-1 as any)).toThrow();
    expect(() => pLimit(1.2 as any)).toThrow();
    expect(() => pLimit(undefined as any)).toThrow();
    expect(() => pLimit(true as any)).toThrow();
  });

  test('change concurrency to smaller value', async () => {
    const limit = pLimit(4);
    let running = 0;
    const log: number[] = [];
    const promises = Array.from({ length: 10 }).map(() =>
      limit(async () => {
        ++running;
        log.push(running);
        await delay(50);
        --running;
      }));
    await delay(0);
    expect(running).toBe(4);

    (limit as any).concurrency = 2;
    await Promise.all(promises);
    expect(log).toEqual([1, 2, 3, 4, 2, 2, 2, 2, 2, 2]);
  });

  test('change concurrency to bigger value', async () => {
    const limit = pLimit(2);
    let running = 0;
    const log: number[] = [];
    const promises = Array.from({ length: 10 }).map(() =>
      limit(async () => {
        ++running;
        log.push(running);
        await delay(50);
        --running;
      }));
    await delay(0);
    expect(running).toBe(2);

    (limit as any).concurrency = 4;
    await Promise.all(promises);
    expect(log).toEqual([1, 2, 3, 4, 4, 4, 4, 4, 4, 4]);
  });

  test('limitFunction()', async () => {
    const concurrency = 5;
    let running = 0;

    const limitedFunction = limitFunction(async () => {
      running++;
      expect(running).toBeLessThanOrEqual(concurrency);
      await delay(randomInt(30, 200));
      running--;
    }, { concurrency });

    const input = Array.from({ length: 100 }, limitedFunction);

    await Promise.all(input);
  });
});