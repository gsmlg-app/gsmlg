import 'dart:collection';

import 'package:meta/meta.dart';

@immutable
class RingBuffer<T> {
  RingBuffer({this.capacity = 60})
      : _items = ListQueue<T>(capacity),
        items = const [];

  RingBuffer._(this.capacity, this._items) : items = List.unmodifiable(_items);

  final int capacity;
  final ListQueue<T> _items;
  final List<T> items;

  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isFull => _items.length >= capacity;

  T? get last => _items.isNotEmpty ? _items.last : null;

  RingBuffer<T> add(T item) {
    final newItems = ListQueue<T>.from(_items);
    if (newItems.length >= capacity) {
      newItems.removeFirst();
    }
    newItems.addLast(item);
    return RingBuffer._(capacity, newItems);
  }
}
