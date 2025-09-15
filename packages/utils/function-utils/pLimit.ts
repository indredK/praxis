/**
 * 本 pLimit 函数的实现，其核心思想和 API 设计
 * heavily inspired by the `p-limit` package by Sindre Sorhus (MIT License).
 * Website: https://github.com/sindresorhus/p-limit
 */
import Queue from './queue';

type LimitFunction = {
  /**
  The number of promises that are currently running.
  */
  readonly activeCount: number;

  /**
  The number of promises that are waiting to run (i.e. their internal `fn` was not called yet).
  */
  readonly pendingCount: number;

  /**
  Get or set the concurrency limit.
  */
  concurrency: number;

  /**
  Discard pending promises that are waiting to run.

  This might be useful if you want to teardown the queue at the end of your program's lifecycle or discard any function calls referencing an intermediary state of your app.

  Note: This does not cancel promises that are already running.
  */
  clearQueue: () => void;

  /**
  Process an array of inputs with limited concurrency.

  The mapper function receives the item value and its index.

  @param array - An array containing an argument for the given function.
  @param mapperFunction - Promise-returning/async function.
  @returns A Promise that returns an array of results.
  */
  map: <Input, ReturnType> (
    array: Input[],
    mapperFunction: (input: Input, index: number) => PromiseLike<ReturnType> | ReturnType
  ) => Promise<ReturnType[]>;

  /**
  @param fn - Promise-returning/async function.
  @param arguments - Any arguments to pass through to `fn`. Support for passing arguments on to the `fn` is provided in order to be able to avoid creating unnecessary closures. You probably don't need this optimization unless you're pushing a lot of functions.
  @returns The promise returned by calling `fn(...arguments)`.
  */
  <Arguments extends unknown[], ReturnType>(
    function_: (...arguments_: Arguments) => PromiseLike<ReturnType> | ReturnType,
    ...arguments_: Arguments
  ): Promise<ReturnType>;
};



type Options = {
  /**
  Concurrency limit.

    Minimum: `1`.
  */
  readonly concurrency: number;
};



// --- Implementation ---

function validateConcurrency(concurrency: number): void {
  if (!((Number.isInteger(concurrency) || concurrency === Number.POSITIVE_INFINITY) && concurrency > 0)) {
    throw new TypeError('Expected `concurrency` to be a number from 1 and up');
  }
}

export default function pLimit(concurrency: number): LimitFunction {
  validateConcurrency(concurrency);

  // The queue stores the functions that will resolve the promises.
  const queue = new Queue<() => void>();
  let activeCount = 0;

  const resumeNext = (): void => {
    // Process the next item in the queue if we are below the concurrency limit.
    if (activeCount < concurrency && queue.size > 0) {
      activeCount++;
      // Dequeue and execute the resolver function.
      queue.dequeue()!();
    }
  };

  const next = (): void => {
    activeCount--;
    resumeNext();
  };

  const run = async <Arguments extends unknown[], ReturnType>(
    fn: (...args: Arguments) => PromiseLike<ReturnType> | ReturnType,
    resolve: (value: Promise<ReturnType>) => void,
    args: Arguments
  ): Promise<void> => {
    const result = (async () => fn(...args))();
    resolve(result);
    // This wrapper ensures `next()` is called regardless of success or failure.
    try {
      await result;
    } catch {
    } finally {
      next();
    }
  };

  type Resolver = (value?: any) => void;  // Type for the internal promise resolver, assuming queue enqueues such functions.

  const enqueue = <Args extends any[], R>(
    function_: (...args: Args) => R | PromiseLike<R>,
    resolve: (value: R) => void,
    arguments_: Args
  ) => {
    // Queue the internal resolve function instead of the run function
    // to preserve the asynchronous execution context.
    new Promise<unknown>(internalResolve => { // eslint-disable-line promise/param-names
      queue.enqueue(internalResolve as Resolver);
    }).then(run.bind(undefined, function_ as any, resolve as any, arguments_)); // eslint-disable-line promise/prefer-await-to-then

    // Start processing immediately if we haven't reached the concurrency limit
    if (activeCount < concurrency) {
      resumeNext();
    }
  };

  const generator = <Arguments extends unknown[], ReturnType>(
    fn: (...args: Arguments) => PromiseLike<ReturnType> | ReturnType,
    ...args: Arguments
  ): Promise<ReturnType> =>
    new Promise(resolve => {
      enqueue(fn, resolve, args);
    });

  // Add properties to the generator function to match the LimitFunction type.
  Object.defineProperties(generator, {
    activeCount: {
      get: () => activeCount,
    },
    pendingCount: {
      get: () => queue.size,
    },
    clearQueue: {
      value: () => {
        queue.clear();
      },
    },
    concurrency: {
      get: () => concurrency,
      set: (newConcurrency: number) => {
        validateConcurrency(newConcurrency);
        concurrency = newConcurrency;
        // Try to resume any pending tasks if the new concurrency limit allows.
        queueMicrotask(() => {
          while (activeCount < concurrency && queue.size > 0) {
            resumeNext();
          }
        });
      },
    },
    map: {
      async value<T, R>(
        array: T[],
        function_: (item: T, index: number) => PromiseLike<R> | R
      ): Promise<R[]> {
        const promises = array.map((value, index) => this(function_, value, index));
        return Promise.all(promises);
      },
    },
  });

  return generator as LimitFunction;
}

export function limitFunction<Arguments extends unknown[], ReturnType>(
  fn: (...args: Arguments) => PromiseLike<ReturnType> | ReturnType,
  options: Options
): (...args: Arguments) => Promise<ReturnType> {
  const { concurrency } = options;
  const limit = pLimit(concurrency);

  // Return a new function that wraps the original function with the concurrency limit.
  return (...args: Arguments) => limit(fn, ...args);
}