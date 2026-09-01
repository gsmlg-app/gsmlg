import 'package:flutter_test/flutter_test.dart';
import 'package:app_system_metrics_macos/app_system_metrics_macos.dart';
import 'package:app_system_metrics_platform_interface/app_system_metrics_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemMetricsMacOS', () {
    test('registers as platform instance', () {
      SystemMetricsMacOS.registerWith();
      expect(SystemMetricsPlatform.instance, isA<SystemMetricsMacOS>());
    });

    test('getData returns a valid map structure', () async {
      final metrics = SystemMetricsMacOS();
      final data = await metrics.getData();

      expect(data['platform'], equals('macos'));
      expect(data['timestamp'], isA<String>());
      expect(data['cpuUsage'], isA<double>());
      expect(data['gpuUsage'], isA<double>());
      expect(data['npuUsage'], equals(0.0));
      expect(data['memoryUsage'], isA<double>());
    });
  });
}
