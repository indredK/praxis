// queue.test.ts
import { test, expect } from 'vitest';
import Queue from '../../function-utils/queue';

test('.enqueue()', () => {
  const queue = new Queue();
  queue.enqueue('🦄');
  expect(queue.dequeue()).toBe('🦄');
  queue.enqueue('🌈');
  queue.enqueue('❤️');
  expect(queue.dequeue()).toBe('🌈');
  expect(queue.dequeue()).toBe('❤️');
});

test('.dequeue()', () => {
  const queue = new Queue();
  expect(queue.dequeue()).toBeUndefined();
  expect(queue.dequeue()).toBeUndefined();
  queue.enqueue('🦄');
  expect(queue.dequeue()).toBe('🦄');
  expect(queue.dequeue()).toBeUndefined();
});

test('.peek()', () => {
  const queue = new Queue();
  expect(queue.peek()).toBeUndefined();
  queue.enqueue('🦄');
  expect(queue.peek()).toBe('🦄');
  queue.enqueue('🌈');
  expect(queue.peek()).toBe('🦄');
  queue.dequeue();
  expect(queue.peek()).toBe('🌈');
  queue.dequeue();
  expect(queue.peek()).toBeUndefined();
});

test('.clear()', () => {
  const queue = new Queue();
  queue.clear();
  queue.enqueue(1);
  queue.clear();
  expect(queue.size).toBe(0);
  queue.enqueue(1);
  queue.enqueue(2);
  queue.enqueue(3);
  queue.clear();
  expect(queue.size).toBe(0);
});

test('.size', () => {
  const queue = new Queue();
  expect(queue.size).toBe(0);
  queue.clear();
  expect(queue.size).toBe(0);
  queue.enqueue('🦄');
  expect(queue.size).toBe(1);
  queue.enqueue('🦄');
  expect(queue.size).toBe(2);
  queue.dequeue();
  expect(queue.size).toBe(1);
  queue.dequeue();
  expect(queue.size).toBe(0);
  queue.dequeue();
  expect(queue.size).toBe(0);
});

test('iterable', () => {
  const queue = new Queue();
  queue.enqueue('🦄');
  queue.enqueue('🌈');
  expect([...queue]).toEqual(['🦄', '🌈']);
});

test('.drain()', () => {
  const queue = new Queue();
  queue.enqueue('🦄');
  queue.enqueue(undefined);
  queue.enqueue('🌈');
  expect([...queue.drain()]).toEqual(['🦄', undefined, '🌈']);
  expect([...queue]).toEqual([]);
  expect(queue.size).toBe(0);
});
