import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsmlg/screens/chat/widgets/system_metrics_indicator.dart';

void main() {
  const channel = MethodChannel('app_system_metrics');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('shows cpu gpu and memory usage when gpu is zero', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method != 'getData') return null;
          return {
            'platform': 'test',
            'timestamp': DateTime(2026).toIso8601String(),
            'cpuUsage': 12.0,
            'gpuUsage': 0.0,
            'npuUsage': 0.0,
            'memoryUsage': 34.0,
          };
        });

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SystemMetricsIndicator())),
    );
    await tester.pump();

    expect(find.text('CPU: 12%'), findsOneWidget);
    expect(find.text('GPU: 0%'), findsOneWidget);
    expect(find.text('MEM: 34%'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
