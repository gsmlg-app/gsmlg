import 'package:app_system_metrics_macos/app_system_metrics_macos.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('app_system_metrics');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
      'macOS activity API forwards to native channel without legacy collectors',
      () async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return <String, Object?>{
        'architecture': 'arm64',
        'monotonic_ms': 1000,
        'cores': <Object?>[],
      };
    });

    final data = await SystemMetricsMacOS().getActivityData();

    expect(calls, ['getActivityData']);
    expect(data['architecture'], 'arm64');
    expect(data['monotonic_ms'], 1000);
  });
}
