import 'dart:async';
import 'dart:io' show stderr;
import 'dart:isolate';

import 'package:app_logging/app_logging.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';

import '../app_duckdb.dart';
import '../duckdb_log_output.dart';
import '../duckdb_log_sink.dart';
import '../log_query_builder.dart';

/// Entry point of the `logstore` isolate; register it with
/// `ChildSpec(name: 'logstore', entryPoint: logStoreEntryPoint,
/// config: {'dbPath': ...})`.
void logStoreEntryPoint(SendPort hubPort) {
  runWorker<Object?>(hubPort, LogStoreWorker.new);
}

/// Owns the DuckDB log store: the only isolate that opens it.
///
/// Records arrive fire-and-forget on the ingest port (see [onCall] `ingestPort`)
/// as `{'k': 'api'|'agent'|'usage', 'r': <toJson map>}`,
/// `{'k': 'system', 'r': <SerializableLogRecord.toMap()>}` or a bare
/// `SerializableLogRecord.toMap()` (as sent by `IsolateLogBridge`), and are
/// batched into DuckDB. Malformed messages are dropped.
///
/// Queries are `call` requests `{'op': String, ...}` mirroring [AppDuckDb];
/// filters travel as [LogFilter.toWire] maps and log rows as raw row maps.
class LogStoreWorker extends Worker<Object?> with WorkerMetricsMixin<Object?> {
  LogStoreWorker(this.context);

  @override
  final WorkerContext context;

  final AppDuckDb _db = AppDuckDb.instance;
  late final DuckDbLogSink _sink;
  late final DuckDbLogOutput _system;
  late final ReceivePort _ingest;
  bool _ready = false;

  @override
  Future<void> onInit(Map<String, dynamic> config) async {
    initMetrics();
    final dbPath = config['dbPath'];
    if (dbPath is! String || dbPath.isEmpty) {
      throw ArgumentError.value(dbPath, 'dbPath', 'required');
    }
    await AppDuckDb.initialize();
    // The connection is process-wide: a previous log store isolate that died
    // without shutting down may have left it open (possibly on this file).
    await _db.close();
    await _db.open(path: dbPath);
    try {
      await _db.ensureLogSchemas();
    } catch (_) {
      await _db.close();
      rethrow;
    }
    _sink = DuckDbLogSink(duckDb: _db);
    _system = DuckDbLogOutput(duckDb: _db);
    _ingest = ReceivePort('logstore.ingest')..listen(_onIngest);
    _ready = true;
  }

  void _onIngest(Object? message) {
    try {
      if (message is! Map) throw FormatException('not a map', message);
      final kind = message['k'];
      if (kind == null && message.containsKey('levelName')) {
        _writeSystem(message);
        return;
      }
      final r = message['r'];
      if (r is! Map) throw FormatException('record is not a map', message);
      final json = r.cast<String, Object?>();
      switch (kind) {
        case 'api':
          _sink.writeApi(ApiExchangeRecord.fromJson(json));
        case 'agent':
          _sink.writeAgent(AgentLogEvent.fromJson(json));
        case 'usage':
          _sink.writeUsage(UsageEvent.fromJson(json));
        case 'system':
          _writeSystem(r);
        default:
          throw FormatException('unknown kind', kind);
      }
      recordSuccess(Duration.zero);
    } catch (e) {
      recordError();
      stderr.writeln('LogStoreWorker: dropped ingest message: $e');
    }
  }

  void _writeSystem(Map<dynamic, dynamic> map) {
    final record = SerializableLogRecord.fromMap(map.cast<String, dynamic>());
    _system.write(record, '');
  }

  @override
  Future<Object?> onTask(
    Object? data, {
    String? taskType,
    Map<String, dynamic>? metadata,
  }) =>
      onCall(data, sender: IsolateAddress.hub, metadata: metadata);

  @override
  Future<Object?> onCall(
    Object? request, {
    required IsolateAddress sender,
    Map<String, dynamic>? metadata,
  }) async {
    if (request is! Map) {
      throw ArgumentError.value(request, 'request', 'expected {op: ...}');
    }
    LogFilter filter() => LogFilter.fromWire(request['filter'] as Map?);
    final op = request['op'];
    switch (op) {
      case 'ingestPort':
        return _ingest.sendPort;
      case 'queryLogs':
        final items = await _db.queryLogs(
          tableOrView: request['tableOrView'] as String,
          filter: filter(),
          limit: request['limit'] as int? ?? 50,
          offset: request['offset'] as int? ?? 0,
        );
        return [for (final i in items) i.rawFields];
      case 'countLogs':
        return _db.countLogs(
          tableOrView: request['tableOrView'] as String,
          filter: filter(),
        );
      case 'listCategories':
        return _db.listCategories();
      case 'queryAgentRuns':
        return _db.queryAgentRuns(
          filter: filter(),
          limit: request['limit'] as int? ?? 50,
          offset: request['offset'] as int? ?? 0,
        );
      case 'countAgentRuns':
        return _db.countAgentRuns(filter: filter());
      case 'deleteOlderThan':
        await _db.deleteOlderThan(
          days: request['days'] as int,
          tables: (request['tables'] as List).cast<String>(),
        );
        return null;
      case 'clearLogsTable':
        await _db.clearLogsTable(table: request['table'] as String);
        return null;
      case 'exportJsonl':
        return _db.exportJsonl(
          table: request['table'] as String,
          filter: filter(),
        );
      case 'queryJson':
        return _db.queryJson(request['sql'] as String);
      case 'flush':
        await Future.wait([_sink.flush(), _system.flush()]);
        return null;
      default:
        throw ArgumentError.value(op, 'op', 'unknown log store op');
    }
  }

  @override
  Future<void> onShutdown() async {
    if (!_ready) return;
    _ingest.close();
    await Future.wait([_sink.close(), _system.close()]);
    await _db.close();
  }
}
