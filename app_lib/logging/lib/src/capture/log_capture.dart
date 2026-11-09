import 'dart:io';

import 'agent_log_event.dart';
import 'api_exchange_record.dart';
import 'usage_event.dart';

abstract interface class LogSink {
  void writeApi(ApiExchangeRecord r);
  void writeAgent(AgentLogEvent e);
  void writeUsage(UsageEvent e);
}

/// Backend-agnostic capture entry point. Never throws into producers.
final class LogCapture {
  LogCapture._();

  static final LogCapture instance = LogCapture._();

  LogSink? _sink;
  bool apiEnabled = true, agentEnabled = true, usageEnabled = true;

  void attach(LogSink? sink) => _sink = sink;

  /// Whether an API record would currently be written (sink attached and
  /// [apiEnabled]). Producers use it to skip capture work cheaply.
  bool get apiActive => apiEnabled && _sink != null;

  void api(ApiExchangeRecord r) =>
      _dispatch(apiEnabled, (s) => s.writeApi(r), 'api');
  void agent(AgentLogEvent e) =>
      _dispatch(agentEnabled, (s) => s.writeAgent(e), 'agent');
  void usage(UsageEvent e) =>
      _dispatch(usageEnabled, (s) => s.writeUsage(e), 'usage');

  void _dispatch(bool enabled, void Function(LogSink) write, String kind) {
    final sink = _sink;
    if (sink == null || !enabled) return;
    try {
      write(sink);
    } catch (e) {
      stderr.writeln('LogCapture: $kind sink failed: $e');
    }
  }
}
