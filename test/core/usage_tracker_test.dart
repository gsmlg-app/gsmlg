import 'package:app_logging/app_logging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/core/usage/usage_tracker.dart';

class _Sink implements LogSink {
  final events = <UsageEvent>[];
  @override
  void writeApi(ApiExchangeRecord r) {}
  @override
  void writeAgent(AgentLogEvent e) {}
  @override
  void writeUsage(UsageEvent e) => events.add(e);
}

void main() {
  late _Sink sink;
  late DateTime now;
  late UsageTracker tracker;

  void advance(int seconds) => now = now.add(Duration(seconds: seconds));

  setUp(() {
    sink = _Sink();
    now = DateTime.utc(2026, 1, 1);
    LogCapture.instance.attach(sink);
    tracker = UsageTracker(clock: () => now, appVersion: '1.2.3');
  });
  tearDown(() => LogCapture.instance.attach(null));

  test('moduleFor maps first segment', () {
    expect(UsageTracker.moduleFor(Uri.parse('/service/github')), 'Service');
    expect(UsageTracker.moduleFor(Uri.parse('/home')), 'Home');
    expect(UsageTracker.moduleFor(Uri.parse('/zzz')), 'Other');
    expect(UsageTracker.moduleFor(Uri.parse('/')), 'Other');
  });

  test('session_start carries platform and version', () {
    tracker.start();
    final e = sink.events.single;
    expect(e.eventType, 'session_start');
    expect(e.sessionId, tracker.sessionId);
    expect(e.payload!['app_version'], '1.2.3');
    expect(e.payload!.containsKey('platform'), isTrue);
  });

  test('route change closes visit with duration', () {
    tracker.start();
    tracker.onRouteChanged(Uri.parse('/toolbox/whois'), 'Whois');
    advance(5);
    tracker.onRouteChanged(Uri.parse('/settings'), null);
    final v = sink.events.last;
    expect(v.eventType, 'screen_view');
    expect(v.module, 'Toolbox');
    expect(v.screenName, 'Whois');
    expect(v.routePath, '/toolbox/whois');
    expect(v.durationMs, 5000);
  });

  test('background time not counted', () {
    tracker.start();
    tracker.onRouteChanged(Uri.parse('/home'), 'Home');
    advance(3);
    tracker.onBackground();
    advance(10);
    tracker.onBackground(); // no-op
    tracker.onForeground();
    advance(2);
    tracker.onRouteChanged(Uri.parse('/settings'), null);
    final views = sink.events.where((e) => e.eventType == 'screen_view');
    expect(views.map((e) => e.durationMs), [3000, 2000]);
    expect(views.last.screenName, 'Home');
    expect(views.last.module, 'Home');
  });

  test('splash not recorded; same route repeated not duplicated', () {
    tracker.start();
    tracker.onRouteChanged(Uri.parse('/'), null);
    advance(2);
    tracker.onRouteChanged(Uri.parse('/home'), 'Home');
    advance(1);
    tracker.onRouteChanged(Uri.parse('/home'), 'Home');
    advance(1);
    tracker.dispose();
    final views = sink.events.where((e) => e.eventType == 'screen_view');
    expect(views.single.durationMs, 2000);
  });

  test('dispose emits view then session_end with total foreground', () {
    tracker.start();
    tracker.onRouteChanged(Uri.parse('/home'), 'Home');
    advance(4);
    tracker.onBackground();
    advance(100);
    tracker.onForeground();
    advance(6);
    tracker.dispose();
    expect(sink.events.map((e) => e.eventType).toList(), [
      'session_start',
      'screen_view',
      'screen_view',
      'session_end',
    ]);
    expect(sink.events[1].durationMs, 4000);
    expect(sink.events[2].durationMs, 6000);
    expect(sink.events.last.durationMs, 10000);
    tracker.dispose();
    expect(sink.events.length, 4);
  });
}
