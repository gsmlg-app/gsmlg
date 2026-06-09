import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_system_metrics/app_system_metrics.dart';

class SystemMetricsIndicator extends StatefulWidget {
  const SystemMetricsIndicator({super.key});

  @override
  State<SystemMetricsIndicator> createState() => _SystemMetricsIndicatorState();
}

class _SystemMetricsIndicatorState extends State<SystemMetricsIndicator> {
  Timer? _timer;

  double _cpu = 0.0;
  double _gpu = 0.0;
  double _memory = 0.0;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    _updateMetrics();

    // Poll every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _updateMetrics());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _updateMetrics() async {
    try {
      final metrics = await SystemMetrics.instance.getData();
      debugPrint('[SystemMetrics] CPU: ${metrics.cpuUsage.toStringAsFixed(1)}%, GPU: ${metrics.gpuUsage.toStringAsFixed(1)}%, MEM: ${metrics.memoryUsage.toStringAsFixed(1)}%');
      if (mounted) {
        setState(() {
          _cpu = metrics.cpuUsage.clamp(0.0, 100.0);
          _gpu = metrics.gpuUsage.clamp(0.0, 100.0);
          _memory = metrics.memoryUsage.clamp(0.0, 100.0);
        });
      }
    } catch (e) {
      debugPrint('[SystemMetrics] Error updating metrics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine whether to show GPU (e.g. only on desktop or if it has non-zero usage)
    final showGpu =
        (Platform.isMacOS || Platform.isLinux || Platform.isWindows) &&
            _gpu > 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MetricPill(
          icon: Icons.memory_outlined,
          label: 'CPU',
          value: _cpu,
          color: const Color(0xFFFF9E0F), // Tailwind Amber/Orange
        ),
        if (showGpu)
          MetricPill(
            icon: Icons.bolt_outlined,
            label: 'GPU',
            value: _gpu,
            color: const Color(0xFFA855F7), // Tailwind Purple
          ),
        MetricPill(
          icon: Icons.donut_large_outlined,
          label: 'MEM',
          value: _memory,
          color: const Color(0xFF06B6D4), // Tailwind Cyan
        ),
      ],
    );
  }
}

class MetricPill extends StatelessWidget {
  const MetricPill({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? color.withAlpha(25) : color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(60),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: ${value.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
