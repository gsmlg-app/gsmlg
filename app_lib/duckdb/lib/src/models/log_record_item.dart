import 'package:equatable/equatable.dart';

/// Supported log levels for querying and display.
enum LogLevel {
  debug,
  info,
  warning,
  error;

  static LogLevel fromString(String? level) {
    switch (level?.toUpperCase()) {
      case 'DEBUG':
      case 'FINE':
      case 'FINER':
      case 'FINEST':
        return LogLevel.debug;
      case 'CONFIG':
      case 'INFO':
        return LogLevel.info;
      case 'WARNING':
      case 'WARN':
        return LogLevel.warning;
      case 'ERROR':
      case 'SEVERE':
      case 'SHOUT':
        return LogLevel.error;
      default:
        return LogLevel.info;
    }
  }

  String get displayName => name.toUpperCase();
}

/// Unified log item for UI display, detail viewing, and export.
class LogRecordItem extends Equatable {
  final String id;
  final DateTime timestamp;
  final String logType; // 'system' | 'api' | 'agent' | 'usage'
  final String? category;
  final LogLevel level;
  final String? loggerName;
  final String message;
  final String? clientAddress;
  final String? status;
  final int? latencyMs;
  final Map<String, dynamic> rawFields;

  const LogRecordItem({
    required this.id,
    required this.timestamp,
    required this.logType,
    this.category,
    required this.level,
    this.loggerName,
    required this.message,
    this.clientAddress,
    this.status,
    this.latencyMs,
    required this.rawFields,
  });

  factory LogRecordItem.fromMap(
    Map<String, dynamic> map, {
    String? defaultType,
  }) {
    final id = map['id']?.toString() ?? '';
    final timeUs = (map['timestamp_us'] as num?)?.toInt() ?? 0;
    final timestamp = DateTime.fromMicrosecondsSinceEpoch(timeUs);
    final logType = (map['log_type'] as String?) ?? defaultType ?? 'system';
    final loggerName = map['logger_name'] as String?;
    final latencyMs = (map['latency_ms'] as num?)?.toInt();

    final isApi = map.containsKey('record_json') && map.containsKey('host');
    final isUsage = map.containsKey('session_id');
    var level = LogLevel.fromString(map['level'] as String?);
    var message = map['message']?.toString() ?? '';
    String? clientAddress = map['isolate_id']?.toString();
    String? status = map['status']?.toString();

    if (isApi) {
      message = [
        map['method'],
        map['host'],
        map['path'],
      ].where((e) => e != null).join(' ').replaceFirst(RegExp(r' (?=/)'), '');
      final code = (map['status'] as num?)?.toInt() ?? 0;
      level = map['has_error'] == true || code >= 400
          ? LogLevel.error
          : LogLevel.info;
    } else if (map.containsKey('summary')) {
      message = map['summary']?.toString() ?? '';
    } else if (isUsage) {
      message = _usageMessage(map);
    }

    return LogRecordItem(
      id: id,
      timestamp: timestamp,
      logType: logType,
      level: level,
      loggerName: loggerName,
      category: map['category'] as String?,
      message: message,
      clientAddress: clientAddress,
      status: status,
      latencyMs: latencyMs,
      rawFields: map,
    );
  }

  static String _usageMessage(Map<String, dynamic> map) {
    final type = map['event_type']?.toString() ?? 'usage';
    if (type == 'menu_tap') return '$type → ${map['target'] ?? ''}'.trim();
    final duration = (map['duration_ms'] as num?)?.toInt();
    final detail = [
      map['module'],
      map['screen_name'] ?? map['target'],
      if (duration != null) '${(duration / 1000).toStringAsFixed(1)}s',
    ].where((e) => e != null && '$e'.isNotEmpty).join(' · ');
    return detail.isEmpty ? type : '$type $detail';
  }

  @override
  List<Object?> get props => [
        id,
        timestamp,
        logType,
        category,
        level,
        loggerName,
        message,
        clientAddress,
        status,
        latencyMs,
        rawFields,
      ];
}
