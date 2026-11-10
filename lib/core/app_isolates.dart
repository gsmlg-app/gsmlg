import 'dart:async';
import 'dart:io' show stderr;
import 'dart:isolate';

import 'package:app_duckdb/app_duckdb.dart';
import 'package:app_logging/app_logging.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:logging/logging.dart' as logging;

/// The app's [IsolateHub] and the `logstore` worker that owns the DuckDB log
/// store. Every log producer (LogCapture and `Logger.root`) writes to it
/// through [forwarder]; the Log Center reads it through [logStore].
class AppIsolates {
  AppIsolates._(this.hub, this.logStore, this.forwarder);

  static const logStoreName = 'logstore';

  final IsolateHub hub;
  final LogStoreClient logStore;
  final LogStoreForwarder forwarder;

  /// Starts the hub and the `logstore` worker on [dbPath], then routes all
  /// logging into it.
  ///
  /// Never throws: when the hub or worker fails, a warning is logged and the
  /// app continues without a log sink (Log Center queries then fail). If the
  /// worker comes up later (supervisor restart), forwarding resumes.
  static Future<AppIsolates> start({required String dbPath}) async {
    final hub = IsolateHub();
    final logStore = LogStoreClient(hub, target: logStoreName);
    final forwarder = LogStoreForwarder(logStore.ingestPort)
      ..listen(hub.events, target: logStoreName);
    try {
      await hub.start();
      await hub.registerService(
        ChildSpec(
          name: logStoreName,
          entryPoint: logStoreEntryPoint,
          config: {'dbPath': dbPath},
        ),
      );
      await forwarder.connect();
    } catch (error, stackTrace) {
      logging.Logger(
        'AppIsolates',
      ).warning('Log store isolate unavailable', error, stackTrace);
    }
    return AppIsolates._(hub, logStore, forwarder);
  }

  /// Writes every log record buffered by the log store so far.
  Future<void> flush() => logStore.flush();

  /// Detaches logging, then stops the hub (the log store flushes and closes
  /// on shutdown).
  Future<void> stop({Duration timeout = const Duration(seconds: 5)}) async {
    forwarder.close();
    await hub.stop(timeout: timeout);
  }
}

/// Forwards LogCapture records ([LogSink]) and `Logger.root` records to the
/// log store's ingest port; re-fetches the port whenever the log store
/// isolate becomes ready again. Never throws into producers; records produced
/// while no port is known are dropped.
class LogStoreForwarder implements LogSink {
  LogStoreForwarder(this._fetchIngestPort) {
    _rootSub = logging.Logger.root.onRecord.listen(writeRoot);
  }

  final Future<SendPort> Function() _fetchIngestPort;
  StreamSubscription<logging.LogRecord>? _rootSub;
  StreamSubscription<HubEvent>? _eventSub;
  SendPort? _port;
  PortLogSink? _sink;
  bool _closed = false;
  int _generation = 0;
  int _applied = 0;

  /// The ingest port records currently go to, or `null` when disconnected.
  SendPort? get ingestPort => _port;

  /// Reconnects whenever the isolate named [target] becomes ready.
  void listen(Stream<HubEvent> events, {required String target}) {
    _eventSub = events.listen((event) {
      if (event is IsolateReady && event.handle.name == target) {
        unawaited(connect());
      }
    });
  }

  /// Fetches the ingest port and attaches to LogCapture; on failure detaches.
  /// A result older than one already applied is ignored.
  Future<void> connect() async {
    final generation = ++_generation;
    SendPort? port;
    try {
      port = await _fetchIngestPort();
    } catch (error) {
      if (!_closed) stderr.writeln('LogStoreForwarder: no ingest port: $error');
    }
    if (_closed || generation < _applied) return;
    _applied = generation;
    _port = port;
    _sink = port == null ? null : PortLogSink(port);
    LogCapture.instance.attach(port == null ? null : this);
  }

  @override
  void writeApi(ApiExchangeRecord r) => _sink?.writeApi(r);

  @override
  void writeAgent(AgentLogEvent e) => _sink?.writeAgent(e);

  @override
  void writeUsage(UsageEvent e) => _sink?.writeUsage(e);

  /// Sends a main-isolate `Logger.root` record as a `system` message.
  void writeRoot(logging.LogRecord record) {
    final port = _port;
    if (port == null) return;
    try {
      port.send({
        'k': 'system',
        'r': SerializableLogRecord.fromLogRecord(record, 'main').toMap(),
      });
    } catch (error) {
      stderr.writeln('LogStoreForwarder: dropped system record: $error');
    }
  }

  /// Stops forwarding and detaches from LogCapture.
  void close() {
    if (_closed) return;
    _closed = true;
    unawaited(_rootSub?.cancel());
    unawaited(_eventSub?.cancel());
    _port = null;
    _sink = null;
    LogCapture.instance.attach(null);
  }
}
