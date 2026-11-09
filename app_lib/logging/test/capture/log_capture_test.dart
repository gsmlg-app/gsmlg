import 'package:app_logging/app_logging.dart';
import 'package:flutter_test/flutter_test.dart';

class _Sink implements LogSink {
  _Sink({this.throws = false});
  final bool throws;
  int api = 0, agent = 0, usage = 0;
  @override
  void writeApi(ApiExchangeRecord r) {
    api++;
    if (throws) throw StateError('boom');
  }

  @override
  void writeAgent(AgentLogEvent e) => agent++;
  @override
  void writeUsage(UsageEvent e) => usage++;
}

ApiExchangeRecord _rec() => ApiExchangeRecord(
      ts: DateTime.now(),
      requestId: 'i',
      recordType: 'exchange',
    );

void main() {
  final c = LogCapture.instance;
  tearDown(() {
    c.attach(null);
    c.apiEnabled = c.agentEnabled = c.usageEnabled = true;
  });

  test('no sink is a no-op', () => c.api(_rec()));
  test('throwing sink does not throw', () {
    final s = _Sink(throws: true);
    c.attach(s);
    expect(() => c.api(_rec()), returnsNormally);
    expect(s.api, 1);
  });
  test('disabled flag suppresses writes', () {
    final s = _Sink();
    c.attach(s);
    c.apiEnabled = false;
    c.api(_rec());
    c.usage(
      UsageEvent(
          ts: DateTime.now(), sessionId: 's', eventType: 'session_start'),
    );
    c.agent(AgentLogEvent(ts: DateTime.now(), eventType: 'e'));
    expect((s.api, s.usage, s.agent), (0, 1, 1));
  });
}
