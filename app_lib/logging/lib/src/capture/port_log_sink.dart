import 'dart:io' show stderr;
import 'dart:isolate';

import 'api_exchange_record.dart';
import 'agent_log_event.dart';
import 'log_capture.dart';
import 'usage_event.dart';

/// [LogSink] that forwards records to the `logstore` isolate's ingest port
/// as `{'k': kind, 'r': record.toJson()}`. Fire-and-forget; never throws.
class PortLogSink implements LogSink {
  PortLogSink(this._ingest);

  final SendPort _ingest;

  @override
  void writeApi(ApiExchangeRecord r) => _send(
        'api',
        () => {
          ...r.toJson(),
          // `response` records omit the request; keep its index summary.
          if (r.request == null) ...{
            'method': r.method,
            'host': r.host,
            'path': r.path,
          },
        },
      );

  @override
  void writeAgent(AgentLogEvent e) => _send('agent', e.toJson);

  @override
  void writeUsage(UsageEvent e) => _send('usage', e.toJson);

  void _send(String kind, Map<String, Object?> Function() record) {
    try {
      _ingest.send({'k': kind, 'r': record()});
    } catch (e) {
      stderr.writeln('PortLogSink: dropped $kind record: $e');
    }
  }
}
