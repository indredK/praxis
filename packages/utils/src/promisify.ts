/**
 * A browser-friendly, TypeScript implementation that mirrors Node.js util.promisify
 * behavior as closely as possible.
 *
 * - Error-first callbacks only.
 * - Resolves with the first success argument.
 * - Preserves `this` when calling the original function.
 * - Honors `original[promisify.custom]` if present and is a function.
 */

type AnyFn = (...args: any[]) => any;

/** Infer the Promise result type from an error-first callback in the last parameter. */
export type Promisified<T extends AnyFn> =
  T extends (...args: [...infer P, (err: any, ...values: infer R) => void]) => any
  ? (...args: P) => Promise<
    R extends [] ? void : // callback(err) only
    R[0]                  // callback(err, value, ...)
  >
  : never;

/** Symbol to match Node.js' util.promisify.custom */
const CUSTOM_SYMBOL: symbol = Symbol.for('nodejs.util.promisify.custom');

/** Overload to attach `.custom` symbol on the function object (like Node). */
export interface Promisify {
  <T extends AnyFn>(original: T): Promisified<T>;
  /** The same symbol Node uses: Symbol.for('nodejs.util.promisify.custom') */
  custom: symbol;
}

/**
 * The promisify function.
 */
export const promisify: Promisify = (function promisifyImpl<T extends AnyFn>(original: T): Promisified<T> {
  if (typeof original !== 'function') {
    throw new TypeError('The "original" argument must be of type Function');
  }

  // If a custom promisified version is provided, return it directly (Node parity).
  const maybeCustom = (original as any)[CUSTOM_SYMBOL];
  if (maybeCustom !== undefined) {
    if (typeof maybeCustom !== 'function') {
      throw new TypeError('The "util.promisify.custom" property must be of type Function');
    }
    return maybeCustom as Promisified<T>;
  }

  // Default wrapper: append our Node-style callback and resolve with first success value.
  function wrapped(this: any, ...args: any[]) {
    return new Promise((resolve, reject) => {
      function callback(err: any, ...values: any[]) {
        if (err != null) {
          reject(err);
          return;
        }
        // Node's util.promisify resolves with the first success argument.
        resolve(values[0]);
      }

      try {
        // Preserve dynamic `this` just like calling original directly.
        (original as AnyFn).apply(this, [...args, callback]);
      } catch (err) {
        // Synchronous throw should reject the Promise.
        reject(err);
      }
    });
  }

  // Optional niceties: set a helpful function name (non-essential, best-effort).
  try {
    Object.defineProperty(wrapped, 'name', {
      value: `promisified ${original.name || 'function'}`,
      configurable: true,
    });
  } catch {
    /* ignore if defineProperty fails (older environments) */
  }

  // For compatibility with some patterns, expose the original via the same symbol on the wrapped fn.
  // (Not required by Node docs, but harmless and occasionally useful.)
  try {
    (wrapped as any)[CUSTOM_SYMBOL] = original;
  } catch {
    /* ignore */
  }

  return wrapped as unknown as Promisified<T>;
}) as any;

// Attach the same well-known custom symbol like Node.
(promisify as any).custom = CUSTOM_SYMBOL;
