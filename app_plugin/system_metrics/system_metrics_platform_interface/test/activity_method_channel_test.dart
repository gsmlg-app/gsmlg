import 'package:app_system_metrics_platform_interface/app_system_metrics_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('app_system_metrics');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('activity request uses the native channel without legacy refresh',
      () async {
    final methods = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      methods.add(call.method);
      return {
        'timestamp_ms': 1234,
        'cores': [
          {'id': 1, 'user': 5000000000}
        ]
      };
    });
    final current = await MethodChannelSystemMetrics().getActivityData();
    expect(methods, ['getActivityData']);
    expect(current['timestamp_ms'], 1234);
    expect((current['cores'] as List).first['user'], 5000000000);
  });

  test('null activity result is a platform error, not an empty sample',
      () async {
    messenger.setMockMethodCallHandler(channel, (call) async => null);
    await expectLater(
      MethodChannelSystemMetrics().getActivityData(),
      throwsA(isA<PlatformException>()
          .having((error) => error.code, 'code', 'NULL_RESULT')),
    );
  });
}
