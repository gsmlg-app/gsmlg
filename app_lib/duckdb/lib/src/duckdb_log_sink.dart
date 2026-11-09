import 'dart:async';
import 'dart:convert';

import 'package:app_logging/app_logging.dart';
import 'package:uuid/uuid.dart';

import 'app_duckdb.dart';
import 'batch_buffer.dart';
import 'rust/api/duckdb.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show PlatformInt64Util;

/// Persists captured API exchanges, agent events and usage events into DuckDB.
///
/// Records are buffered and written in batches; failures go to stderr and
/// never reach producers.
class DuckDbLogSink implements LogSink {
  DuckDbLogSink({
    required this.duckDb,
    this.flushInterval = const Duration(milliseconds: 500),
    this.threshold = 50,
  }) {
    if (flushInterval > Duration.zero) {
      _timer = Timer.periodic(flushInterval, (_) => _triggerFlush());
    }
  }

  final AppDuckDb duckDb;
  final Duration flushInterval;
  final int threshold;

  static const _uuid = Uuid();

  late final BatchBuffer<ApiExchangeEntry> _api = BatchBuffer(
    name: 'DuckDbLogSink.api',
    threshold: threshold,
    write: (b) => duckDb.batchAppendApiExchanges(b),
  );
  late final BatchBuffer<AgentEventEntry> _agent = BatchBuffer(
    name: 'DuckDbLogSink.agent',
    threshold: threshold,
    write: (b) => duckDb.batchAppendAgentEvents(b),
  );
  late final BatchBuffer<UsageEventEntry> _usage = BatchBuffer(
    name: 'DuckDbLogSink.usage',
    threshold: threshold,
    write: (b) => duckDb.batchAppendUsageEvents(b),
  );

  Timer? _timer;
  bool _isClosed = false;

  @override
  void writeApi(ApiExchangeRecord r) {
    if (_isClosed) return;
    final req = r.request, res = r.response, ctx = r.context;
    if (_api.add(
      ApiExchangeEntry(
        id: _uuid.v4(),
        timestampUs:
            PlatformInt64Util.from(r.ts.toUtc().microsecondsSinceEpoch),
        requestId: r.requestId,
        recordType: r.recordType,
        category: r.category,
        apiType: r.apiType,
        method: req?.method,
        host: req?.host,
        path: req?.uri,
        status: res?.status,
        durationMs: r.durationMs,
        hasError: r.error != null,
        aborted: r.aborted,
        conversationId: ctx?.conversationId,
        runId: ctx?.runId,
        turn: ctx?.turn,
        toolCallId: ctx?.toolCallId,
        recordJson: r.toJsonLine(),
      ),
    )) {
      _api.trigger();
    }
  }

  @override
  void writeAgent(AgentLogEvent e) {
    if (_isClosed) return;
    if (_agent.add(
      AgentEventEntry(
        id: _uuid.v4(),
        timestampUs:
            PlatformInt64Util.from(e.ts.toUtc().microsecondsSinceEpoch),
        eventType: e.eventType,
        conversationId: e.context.conversationId,
        runId: e.context.runId,
        parentRunId: e.context.parentRunId,
        turn: e.context.turn,
        toolCallId: e.context.toolCallId,
        toolName: e.toolName,
        backend: e.backend,
        requestId: e.requestId,
        level: e.level,
        isError: e.isError,
        durationMs: e.durationMs,
        summary: e.summary,
        payloadJson: _encodePayload(e.payload),
      ),
    )) {
      _agent.trigger();
    }
  }

  @override
  void writeUsage(UsageEvent e) {
    if (_isClosed) return;
    final duration = e.durationMs;
    if (_usage.add(
      UsageEventEntry(
        id: _uuid.v4(),
        timestampUs:
            PlatformInt64Util.from(e.ts.toUtc().microsecondsSinceEpoch),
        sessionId: e.sessionId,
        eventType: e.eventType,
        module: e.module,
        screenName: e.screenName,
        routePath: e.routePath,
        target: e.target,
        sourceScreen: e.sourceScreen,
        durationMs: duration == null ? null : PlatformInt64Util.from(duration),
        payloadJson: _encodePayload(e.payload),
      ),
    )) {
      _usage.trigger();
    }
  }

  static String? _encodePayload(Map<String, Object?>? payload) =>
      payload == null ? null : jsonEncode(payload);

  void _triggerFlush() {
    if (_isClosed) return;
    _api.trigger();
    _agent.trigger();
    _usage.trigger();
  }

  /// Writes everything buffered so far.
  Future<void> flush() async {
    await Future.wait([_api.flush(), _agent.flush(), _usage.flush()]);
  }

  Future<void> close() async {
    _isClosed = true;
    _timer?.cancel();
    _timer = null;
    await flush();
  }
}
