import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:hive_ce/hive_ce.dart';

enum SessionSnapshotKind { exit, recovery, workspace, group }

class SessionSnapshot {
  SessionSnapshot({
    required this.id,
    required this.kind,
    required this.createdAt,
    required Map<String, dynamic> layout,
    this.name,
  }) : _layout = _copyLayout(layout);

  final String id;
  final SessionSnapshotKind kind;
  final DateTime createdAt;
  final String? name;
  final Map<String, dynamic> _layout;

  Map<String, dynamic> get layout =>
      jsonDecode(jsonEncode(_layout)) as Map<String, dynamic>;

  Map<String, dynamic> toJson() => {
    'schemaVersion': 1,
    'id': id,
    'kind': kind.name,
    'createdAt': createdAt.toUtc().toIso8601String(),
    if (name != null) 'name': name,
    'layout': _layout,
  };

  factory SessionSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] is int && json['schemaVersion'] != 1) {
      throw const FormatException('Unsupported session snapshot version');
    }
    if (json['schemaVersion'] != 1) {
      throw const FormatException('Invalid session snapshot');
    }
    final id = json['id'];
    if (id is! String || !RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(id)) {
      throw const FormatException('Invalid session snapshot id');
    }
    return SessionSnapshot(
      id: id,
      kind: SessionSnapshotKind.values.byName(json['kind'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      name: json['name'] as String?,
      layout: json['layout'] as Map<String, dynamic>,
    );
  }
}

Map<String, dynamic> _copyLayout(Map<String, dynamic> layout) {
  final rawTabs = layout['tabs'];
  if (rawTabs is! List) throw const FormatException('Missing session tabs');
  final tabs = <Map<String, dynamic>>[];
  for (final raw in rawTabs) {
    if (raw is! Map || !{'local', 'ssh', 'sftp'}.contains(raw['type'])) {
      throw const FormatException('Invalid session tab');
    }
    tabs.add({
      'type': raw['type'],
      for (final key in ['profileId', 'hostId'])
        if (raw[key] is int) key: raw[key],
      for (final key in ['workingDirectory', 'groupId', 'customTitle'])
        if (raw[key] is String) key: raw[key],
    });
  }
  final groups = <Map<String, dynamic>>[];
  if (layout['groups'] case final List rawGroups) {
    for (final raw in rawGroups) {
      if (raw is! Map || raw['id'] is! String || raw['name'] is! String) {
        continue;
      }
      groups.add({
        'id': raw['id'],
        'name': raw['name'],
        'collapsed': raw['collapsed'] == true,
      });
    }
  }
  return {
    'activeIndex': layout['activeIndex'] is int ? layout['activeIndex'] : 0,
    'tabs': tabs,
    if (groups.isNotEmpty) 'groups': groups,
    if (layout['ungroupedCollapsed'] == true) 'ungroupedCollapsed': true,
  };
}

/// A single-instance Hive journal. Every acknowledged change is flushed before
/// it is considered recorded. Snapshot values are copied before queuing writes.
class SessionStore {
  SessionStore._(this.directory, this._box, this._now);

  final Directory directory;
  final Box<dynamic> _box;
  final DateTime Function() _now;
  final _random = Random.secure();
  Future<void> _pending = Future<void>.value();
  SessionSnapshot? _current;
  String? _currentId;
  SessionSnapshot? recovery;
  final List<SessionSnapshot> _history = [];
  final List<SessionSnapshot> _saved = [];
  bool _finished = false;
  Object? _writeError;

  List<SessionSnapshot> get history => List.unmodifiable(_history);
  List<SessionSnapshot> get saved => List.unmodifiable(_saved);
  SessionSnapshot? get current => _current;
  SessionSnapshot? get latest {
    final candidates = [?recovery, ..._history];
    candidates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return candidates.firstOrNull;
  }

  static Future<SessionStore> open(
    Directory directory, {
    DateTime Function()? now,
    String? legacy,
    Box<dynamic>? storage,
  }) async {
    await directory.create(recursive: true);
    final box =
        storage ??
        await Hive.openBox<dynamic>('sessions', path: directory.path);
    final store = SessionStore._(directory, box, now ?? DateTime.now);
    try {
      await store._load(legacy);
      return store;
    } catch (_) {
      await box.close();
      rethrow;
    }
  }

  String _id() =>
      '${_now().microsecondsSinceEpoch}-${_random.nextInt(0x100000000).toRadixString(16)}';

  SessionSnapshot? _read(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      final json = Map<String, dynamic>.from(raw as Map);
      return SessionSnapshot.fromJson(
        jsonDecode(jsonEncode(json)) as Map<String, dynamic>,
      );
    } on FormatException catch (error) {
      if (error.message == 'Unsupported session snapshot version') rethrow;
      return null;
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  Future<void> _load(String? legacy) async {
    // Validate all records before mutating the journal, including newer schemas.
    recovery = _read('recovery');
    for (final key in _box.keys.whereType<String>()) {
      final target = key.startsWith('history/')
          ? _history
          : key.startsWith('saved/')
          ? _saved
          : null;
      if (target == null) continue;
      final snapshot = _read(key);
      if (snapshot != null) target.add(snapshot);
    }
    _history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _saved.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final interrupted = _read('current') ?? _read('current.previous');
    if (interrupted != null) {
      // If exit was interrupted after archiving, that archive already owns it.
      if (!_history.any((snapshot) => snapshot.id == interrupted.id)) {
        recovery = SessionSnapshot(
          id: interrupted.id,
          kind: SessionSnapshotKind.recovery,
          createdAt: interrupted.createdAt,
          layout: interrupted.layout,
        );
        await _box.put('recovery', recovery!.toJson());
        await _box.flush();
      }
      await _box.deleteAll(['current', 'current.previous']);
      await _box.flush();
    }
    if (legacy != null && _box.get('legacyImported') != true) {
      if (recovery == null && _history.isEmpty) {
        recovery = SessionSnapshot(
          id: _id(),
          kind: SessionSnapshotKind.recovery,
          createdAt: _now(),
          layout: jsonDecode(legacy) as Map<String, dynamic>,
        );
        await _box.put('recovery', recovery!.toJson());
      }
      await _box.put('legacyImported', true);
      await _box.flush();
    }
    await _rotateHistory();
  }

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  Future<void> record(Map<String, dynamic> layout) {
    final captured = SessionSnapshot(
      id: _currentId ??= _id(),
      kind: SessionSnapshotKind.recovery,
      createdAt: _now(),
      layout: layout,
    );
    return _enqueue(() async {
      if (_finished) return;
      try {
        await _box.putAll({
          if (_current != null) 'current.previous': _current!.toJson(),
          'current': captured.toJson(),
        });
        await _box.flush();
        _current = captured;
        _writeError = null;
      } catch (error) {
        _writeError = error;
        rethrow;
      }
    });
  }

  Future<SessionSnapshot> save(
    String name,
    Map<String, dynamic> layout, {
    bool group = false,
  }) {
    final captured = SessionSnapshot(
      id: _id(),
      kind: group ? SessionSnapshotKind.group : SessionSnapshotKind.workspace,
      createdAt: _now(),
      name: name.trim(),
      layout: layout,
    );
    return _enqueue(() async {
      await _box.put('saved/${captured.id}', captured.toJson());
      await _box.flush();
      _saved.insert(0, captured);
      return captured;
    });
  }

  Future<void> deleteSaved(String id) => _enqueue(() async {
    if (!_saved.any((snapshot) => snapshot.id == id)) return;
    await _box.delete('saved/$id');
    await _box.flush();
    _saved.removeWhere((snapshot) => snapshot.id == id);
  });

  Future<void> flush() async {
    await _pending;
    if (_writeError case final Object error) throw error;
    await _box.flush();
  }

  Future<void> finishExit() => _enqueue(() async {
    if (_finished) return;
    if (_writeError case final Object error) throw error;
    final current = _current;
    if (current != null) {
      final snapshot = SessionSnapshot(
        id: current.id,
        kind: SessionSnapshotKind.exit,
        createdAt: _now(),
        layout: current.layout,
      );
      await _box.put('history/${snapshot.id}', snapshot.toJson());
      await _box.flush();
      _history.removeWhere((entry) => entry.id == snapshot.id);
      _history.insert(0, snapshot);
      await _box.deleteAll(['current', 'current.previous']);
      await _box.flush();
      _current = null;
      await _rotateHistory();
    }
    _finished = true;
  });

  Future<void> _rotateHistory() async {
    while (_history.length > 5) {
      final oldest = _history.last;
      await _box.delete('history/${oldest.id}');
      await _box.flush();
      _history.removeLast();
    }
  }

  Future<void> close() async {
    await _pending;
    await _box.close();
  }
}
