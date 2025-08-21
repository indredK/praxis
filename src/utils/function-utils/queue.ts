/**
 * Tiny queue implemented with a singly-linked list.
 *
 * 用法与原实现一致，支持泛型：
 * const q = new Queue<string>();
 * q.enqueue('a');
 * q.enqueue('b');
 * console.log(q.size); // 2
 * console.log(...q); // 'a', 'b'
 * for (const v of q.drain()) { ... } // 逐个取出并清空队列
 */

class Node<T> {
  public value: T;
  public next?: Node<T>;

  constructor(value: T) {
    this.value = value;
    this.next = undefined;
  }
}

export default class Queue<ValueType> implements Iterable<ValueType> {
  // 内部节点引用（使用普通 private 而不是 # 私有字段以兼容 TypeScript 常见配置）
  private _head?: Node<ValueType>;
  private _tail?: Node<ValueType>;
  private _size: number = 0;

  /**
   * 只读的 size（通过 getter 暴露）
   */
  constructor() {
    this.clear();
  }

  /**
   * 支持 `for ... of` 从头到尾遍历（不移除元素）
   */
  *[Symbol.iterator](): IterableIterator<ValueType> {
    let current = this._head;
    while (current) {
      yield current.value;
      current = current.next;
    }
  }

  /**
   * 返回一个会在遍历时逐个 dequeue 的迭代器，用于“消费并清空”队列
   */
  * drain(): IterableIterator<ValueType | undefined> {
    // 注意：dequeue 在队列为空时返回 undefined，但这里的循环保证不会产出 undefined
    while (this._head) {
      yield this.dequeue();
    }
  }

  /**
   * 入队
   */
  enqueue(value: ValueType): void {
    const node = new Node<ValueType>(value);

    if (this._head) {
      // 追加到尾部
      this._tail!.next = node;
      this._tail = node;
    } else {
      // 队列为空
      this._head = node;
      this._tail = node;
    }

    this._size++;
  }

  /**
   * 出队（返回被移除的值，队列为空时返回 undefined）
   */
  dequeue(): ValueType | undefined {
    const current = this._head;
    if (!current) {
      return undefined;
    }

    // 把头移到下一个节点
    this._head = current.next;

    // 如果移除后队列为空，确保 tail 也被清除
    if (!this._head) {
      this._tail = undefined;
    }

    this._size--;
    return current.value;
  }

  /**
   * 获取队首但不移除，空队列返回 undefined
   */
  peek(): ValueType | undefined {
    return this._head ? this._head.value : undefined;
  }

  /**
   * 清空队列
   */
  clear(): void {
    this._head = undefined;
    this._tail = undefined;
    this._size = 0;
  }

  /**
   * 只读 size
   */
  get size(): number {
    return this._size;
  }
}
