import 'package:app_system_metrics_platform_interface/app_system_metrics_platform_interface.dart';
import 'package:monitor_agent/monitor_agent.dart';
import 'package:monitor_models/monitor_models.dart';

/// The macOS implementation of [SystemMetricsPlatform].
class SystemMetricsMacOS extends SystemMetricsPlatform {
  /// Registers this class as the default instance of [SystemMetricsPlatform].
  static void registerWith() {
    SystemMetricsPlatform.instance = SystemMetricsMacOS();
  }

  MetricsCollector<CpuMetrics>? _cpuCollector;
  MetricsCollector<MemoryMetrics>? _memoryCollector;
  MetricsCollector<List<GpuMetrics>>? _gpuCollector;

  SystemMetricsMacOS() {
    try {
      _cpuCollector = createCpuCollector();
      _memoryCollector = createMemoryCollector();
      _gpuCollector = createGpuCollector();
    } catch (_) {
      // Fallback
    }
  }

  @override
  Future<Map<String, dynamic>> getData() async {
    double cpuVal = 0.0;
    double gpuVal = 0.0;
    double memVal = 0.0;

    try {
      if (_cpuCollector != null) {
        final cpuM = await _cpuCollector!.collect();
        if (cpuM != null) {
          cpuVal = cpuM.usagePercent;
        }
      }
    } catch (_) {}

    try {
      if (_memoryCollector != null) {
        final memM = await _memoryCollector!.collect();
        if (memM != null && memM.totalBytes > 0) {
          memVal = (memM.usedBytes / memM.totalBytes) * 100.0;
        }
      }
    } catch (_) {}

    try {
      if (_gpuCollector != null) {
        final gpuList = await _gpuCollector!.collect();
        if (gpuList != null && gpuList.isNotEmpty) {
          gpuVal = gpuList
              .map((g) => g.usagePercent)
              .fold(0.0, (a, b) => a > b ? a : b);
        }
      }
    } catch (_) {}

    return {
      'platform': 'macos',
      'timestamp': DateTime.now().toIso8601String(),
      'cpuUsage': cpuVal,
      'gpuUsage': gpuVal,
      'npuUsage': 0.0,
      'memoryUsage': memVal,
    };
  }
}
