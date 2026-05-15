import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class RingBuffer<T> {
  RingBuffer({this.capacity = 60}) : _items = ListQueue<T>(capacity);

  final int capacity;
  final ListQueue<T> _items;

  List<T> get items => List.unmodifiable(_items);
  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isFull => _items.length >= capacity;

  T? get last => _items.isNotEmpty ? _items.last : null;

  RingBuffer<T> add(T item) {
    final buf = RingBuffer<T>(capacity: capacity);
    buf._items.addAll(_items);
    if (buf._items.length >= capacity) {
      buf._items.removeFirst();
    }
    buf._items.addLast(item);
    return buf;
  }
}
