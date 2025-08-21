// =================================================================
// 接口定义 (Interface Definitions)
// =================================================================

export interface FlattenOptions {
  delimiter?: string;
  maxDepth?: number;
  safe?: boolean; // If true, arrays will not be flattened
  transformKey?: (key: string) => string;
}

export interface UnflattenOptions {
  delimiter?: string;
  object?: boolean; // If true, numeric keys will be treated as strings
  overwrite?: boolean;
  transformKey?: (key: string) => string;
}

// =================================================================
// 辅助函数 (Helper Functions)
// =================================================================

/**
 * 检查一个对象是否是 Buffer。
 * 这是 Node.js 环境中常见的检查，在浏览器中通常会返回 false。
 */
function isBuffer(obj: any): boolean {
  return obj &&
    obj.constructor &&
    (typeof obj.constructor.isBuffer === 'function') &&
    obj.constructor.isBuffer(obj);
}

/**
 * 默认的 key 转换函数，直接返回原始 key。
 */
function keyIdentity(key: string): string {
  return key;
}

// =================================================================
// `flatten` 实现 (flatten Implementation)
// =================================================================

export function flatten(target: any, opts: FlattenOptions = {}): Record<string, any> {
  const delimiter = opts.delimiter || '.';
  const maxDepth = opts.maxDepth || 0;
  const transformKey = opts.transformKey || keyIdentity;
  const output: Record<string, any> = {};

  function step(object: any, prev?: string, currentDepth?: number): void {
    currentDepth = currentDepth || 1;
    Object.keys(object).forEach(function (key) {
      const value = object[key];
      const isarray = opts.safe && Array.isArray(value);
      const type = Object.prototype.toString.call(value);
      const isbuffer = isBuffer(value);
      const isobject = (
        type === '[object Object]' ||
        type === '[object Array]'
      );

      const newKey = prev
        ? prev + delimiter + transformKey(key)
        : transformKey(key);

      if (!isarray && !isbuffer && isobject && Object.keys(value).length &&
        (!opts.maxDepth || currentDepth < maxDepth)) {
        return step(value, newKey, currentDepth + 1);
      }

      output[newKey] = value;
    });
  }

  step(target);

  return output;
}

// =================================================================
// `unflatten` 实现 (unflatten Implementation)
// =================================================================

export function unflatten(target: any, opts: UnflattenOptions = {}): any {
  const delimiter = opts.delimiter || '.';
  const overwrite = opts.overwrite || false;
  // 注意：`transformKey` 在 unflatten 中实际上不应该被用于分割路径
  // const transformKey = opts.transformKey || keyIdentity; // 这行保留，但我们不在分割时使用它
  const result: Record<string, any> = {};

  if (isBuffer(target) || Object.prototype.toString.call(target) !== '[object Object]') {
    return target;
  }

  function getkey(key: string): string | number {
    const parsedKey = Number(key);
    return (
      isNaN(parsedKey) ||
      key.indexOf('.') !== -1 ||
      opts.object
    ) ? key : parsedKey;
  }

  const preprocessedTarget = Object.keys(target).reduce<Record<string, any>>(function (result, key) {
    const value = target[key];
    const type = Object.prototype.toString.call(value);
    const isObject = (type === '[object Object]' || type === '[object Array]');
    if (!isObject || !Object.keys(value).length) {
      result[key] = value;
      return result;
    } else {
      Object.keys(value).forEach(function (childKey) {
        const newKey = key + delimiter + childKey;
        result[newKey] = value[childKey];
      });
      return result;
    }
  }, {});


  Object.keys(preprocessedTarget).forEach(function (key) {
    // *** 核心修复点 ***
    // 原始错误的行: const split = key.split(delimiter).map(transformKey);
    // 正确的逻辑: 直接分割即可，因为键已经是转换后的形态。
    const split = key.split(delimiter);

    let key1 = getkey(split.shift()!);
    let key2 = getkey(split[0]);
    let recipient: any = result;

    while (key2 !== undefined) {
      if (key1 === '__proto__') {
        return;
      }

      const type = Object.prototype.toString.call(recipient[key1]);
      const isobject = (
        type === '[object Object]' ||
        type === '[object Array]'
      );

      if (!overwrite && !isobject && typeof recipient[key1] !== 'undefined') {
        return;
      }

      if ((overwrite && !isobject) || (!overwrite && recipient[key1] == null)) {
        recipient[key1] = (
          typeof key2 === 'number' && !opts.object
            ? []
            : {}
        );
      }

      recipient = recipient[key1];
      if (split.length > 0) {
        key1 = getkey(split.shift()!);
        key2 = getkey(split[0]);
      }
    }

    recipient[key1] = unflatten(preprocessedTarget[key], opts);
  });

  return result;
}