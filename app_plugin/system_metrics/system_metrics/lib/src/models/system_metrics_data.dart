/// Data model for SystemMetrics.
class SystemMetricsData {
  /// Creates a SystemMetricsData instance.
  const SystemMetricsData({
    required this.platform,
    required this.timestamp,
    required this.cpuUsage,
    required this.gpuUsage,
    required this.npuUsage,
    required this.memoryUsage,
    this.additionalData = const {},
  });

  /// The platform name (e.g., 'android', 'ios', 'linux').
  final String platform;

  /// The timestamp when this data was collected.
  final DateTime timestamp;

  /// CPU usage percentage (0.0 to 100.0).
  final double cpuUsage;

  /// GPU usage percentage (0.0 to 100.0).
  final double gpuUsage;

  /// NPU usage percentage (0.0 to 100.0).
  final double npuUsage;

  /// Memory usage percentage (0.0 to 100.0).
  final double memoryUsage;

  /// Additional platform-specific data.
  final Map<String, dynamic> additionalData;

  /// Creates a SystemMetricsData from a map.
  factory SystemMetricsData.fromMap(Map<String, dynamic> map) {
    return SystemMetricsData(
      platform: map['platform'] as String? ?? 'unknown',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      cpuUsage: (map['cpuUsage'] as num?)?.toDouble() ?? 0.0,
      gpuUsage: (map['gpuUsage'] as num?)?.toDouble() ?? 0.0,
      npuUsage: (map['npuUsage'] as num?)?.toDouble() ?? 0.0,
      memoryUsage: (map['memoryUsage'] as num?)?.toDouble() ?? 0.0,
      additionalData: Map<String, dynamic>.from(
        (map['additionalData'] as Map<dynamic, dynamic>?) ?? {},
      ),
    );
  }

  /// Converts this SystemMetricsData to a map.
  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'timestamp': timestamp.toIso8601String(),
      'cpuUsage': cpuUsage,
      'gpuUsage': gpuUsage,
      'npuUsage': npuUsage,
      'memoryUsage': memoryUsage,
      'additionalData': additionalData,
    };
  }

  @override
  String toString() {
    return 'SystemMetricsData(platform: $platform, timestamp: $timestamp, cpu: $cpuUsage%, gpu: $gpuUsage%, npu: $npuUsage%, memory: $memoryUsage%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SystemMetricsData &&
        other.platform == platform &&
        other.timestamp == timestamp &&
        other.cpuUsage == cpuUsage &&
        other.gpuUsage == gpuUsage &&
        other.npuUsage == npuUsage &&
        other.memoryUsage == memoryUsage;
  }

  @override
  int get hashCode {
    return platform.hashCode ^
        timestamp.hashCode ^
        cpuUsage.hashCode ^
        gpuUsage.hashCode ^
        npuUsage.hashCode ^
        memoryUsage.hashCode;
  }
}
