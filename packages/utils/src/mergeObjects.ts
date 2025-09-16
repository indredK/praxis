/**
 * 定义了合并两个值时可以使用的策略类型。
 * 包括预设的关键字和自定义的处理函数。
 */
type MergeStrategyType = 'overwrite' | 'concat' | 'union' | 'intersection' | 'max' | 'min' | ((a: any, b: any) => any);

/**
 * 为 mergeObjects 函数提供详细的配置选项，以自定义合并行为。
 */
export interface MergeConfig {
  /**
   * 控制合并是深度合并还是浅合并。
   * - `true` (默认): 递归合并所有嵌套的对象。
   * - `false`: 只合并顶层属性，如果属性值为对象，则直接覆盖。
   */
  deep?: boolean;

  /**
   * 为特定的键或路径（使用点 `.` 表示法）指定自定义合并策略。
   * 例如: `{ 'user.settings.volume': 'max' }`
   */
  strategy?: Record<string, MergeStrategyType>;

  /**
   * 一个由键或路径（使用点 `.` 表示法）组成的数组，用于在合并过程中排除某些属性。
   */
  exclude?: string[];

  /**
   * 合并数组时的默认策略。
   * - `concat` (默认): 连接两个数组。
   * - `union`: 合并数组并移除重复项。
   * - `overwrite`: 用第二个数组完全替换第一个数组。
   * - `intersection`: 只保留两个数组中都存在的元素。
   */
  arrayMerge?: 'concat' | 'union' | 'overwrite' | 'intersection';

  /**
   * 定义如何处理来自源对象 (`objB`) 的 `null` 或 `undefined` 值。
   * - `overwrite` (默认): 用 `null` 或 `undefined` 覆盖目标值。
   * - `skip`: 保留目标值，忽略源对象的 `null` 或 `undefined`。
   * - `default`: 类似于 `skip`，但如果目标值也是 `null` 或 `undefined`，则使用源值。
   */
  nullBehavior?: 'skip' | 'overwrite' | 'default';

  /**
   * 定义当同一路径下的属性类型不同时如何处理。
   * - `overwrite` (默认): 源对象的属性值覆盖目标对象的属性值。
   * - `error`: 抛出一个错误。
   * - `skip`: 保留目标对象的属性值，忽略源对象的。
   */
  typeConflict?: 'overwrite' | 'error' | 'skip';

  /**
   * 一个在合并过程开始前对每个输入对象（objA, objB）进行预处理的函数。
   * @param obj 输入的对象。
   * @returns 转换后的对象。
   */
  preMerge?: (obj: any) => any;

  /**
   * 一个在合并过程结束后对最终结果进行后处理的函数。
   * @param obj 合并后的对象。
   * @returns 最终转换后的对象。
   */
  postMerge?: (obj: any) => any;

  /**
   * 一个函数，用于根据特定条件决定是否合并某个属性。
   * 如果返回 `false`，则该属性的合并操作将被跳过。
   * @param key 当前属性的键名。
   * @param valueA 来自第一个对象的值。
   * @param valueB 来自第二个对象的值。
   * @param path 到达当前属性的路径数组。
   * @returns `true` 表示允许合并，`false` 表示阻止合并。
   */
  condition?: (key: string, valueA: any, valueB: any, path: string[]) => boolean;

  /**
   * 一个用于校验最终合并结果是否符合预定模式的函数。
   * 如果校验失败（返回 `false`），函数将抛出一个错误。
   * @param obj 最终合并的对象。
   * @returns `true` 表示校验通过，`false` 表示校验失败。
   */
  schemaValidate?: (obj: any) => boolean;
}


/**
 * 根据丰富的配置选项，递归地合并两个对象或值。
 * 这是一个功能强大的工具，用于处理复杂的数据结构合并。
 * @param objA 基础对象，将被合并到的目标。
 * @param objB 源对象，其属性将被合并到基础对象中。
 * @param config 一个 `MergeConfig` 对象，用于自定义合并的行为。
 * @returns 返回一个全新的、合并后的对象。
 * @see MergeConfig
 * @example
 * const defaults = { settings: { theme: 'dark', notifications: { enabled: true } } };
 * const userPrefs = { settings: { notifications: { enabled: false, sound: 'ding' } } };
 * const finalSettings = mergeObjects(defaults, userPrefs);
 * // finalSettings will be: { settings: { theme: 'dark', notifications: { enabled: false, sound: 'ding' } } }
 */
export function mergeObjects(objA: any, objB: any, config: MergeConfig = {}): any {
  const {
    deep = true,
    strategy = {},
    exclude = [],
    arrayMerge = 'concat',
    nullBehavior = 'overwrite',
    typeConflict = 'overwrite',
    preMerge,
    postMerge,
    condition,
    schemaValidate,
  } = config;

  if (preMerge) {
    objA = preMerge(objA);
    objB = preMerge(objB);
  }

  /**
   * 检查一个值是否是严格意义上的对象（而不是数组或 null）。
   * @internal
   */
  function isObject(val: any) {
    return val && typeof val === 'object' && !Array.isArray(val);
  }

  // 内部递归合并函数
  function merge(a: any, b: any, path: string[] = []): any {
    const currPath = path.join('.');

    if (exclude.includes(currPath)) return a;

    if (condition && path.length > 0 && !condition(path[path.length - 1] || '', a, b, path)) {
      return a;
    }

    if (a !== undefined && b !== undefined && typeof a !== typeof b) {
      if (typeConflict === 'error') throw new Error(`Type conflict at ${currPath}`);
      if (typeConflict === 'skip') return a;
    }
    if (b === undefined || b === null) {
      if (nullBehavior === 'skip') return a;
      if (nullBehavior === 'default') return a ?? b;
    }
    if (strategy[currPath]) {
      const strat = strategy[currPath];
      if (typeof strat === 'function') return strat(a, b);
      if (strat === 'max') return Math.max(a, b);
      if (strat === 'min') return Math.min(a, b);
      if (strat === 'concat' && Array.isArray(a) && Array.isArray(b)) return [...a, ...b];
      if (strat === 'union' && Array.isArray(a) && Array.isArray(b)) return Array.from(new Set([...a, ...b]));
      if (strat === 'intersection' && Array.isArray(a) && Array.isArray(b)) return a.filter((v: any) => b.includes(v));
      if (strat === 'overwrite') return b;
    }
    if (Array.isArray(a) && Array.isArray(b)) {
      if (arrayMerge === 'concat') return [...a, ...b];
      if (arrayMerge === 'union') return Array.from(new Set([...a, ...b]));
      if (arrayMerge === 'intersection') return a.filter((v: any) => b.includes(v));
      if (arrayMerge === 'overwrite') return b;
    }

    if (isObject(a) && isObject(b)) {
      // 如果是浅合并，执行类似 Object.assign 的行为并立即返回
      if (!deep) {
        return { ...a, ...b };
      }

      // 否则，执行深度合并逻辑
      const result: any = {};
      const keys = Array.from(new Set([...Object.keys(a), ...Object.keys(b)]));
      for (const key of keys) {
        result[key] = merge(a[key], b[key], [...path, key]);
      }
      return result;
    }

    // 默认覆盖
    return b !== undefined ? b : a;
  }

  const merged = merge(objA, objB);

  const final = postMerge ? postMerge(merged) : merged;

  if (schemaValidate && !schemaValidate(final)) {
    throw new Error('Schema validation failed!');
  }

  return final;
}