import 'dart:convert';
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
  final String logType; // 'system' | 'dns' | 'dhcp'
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
    final level = LogLevel.fromString(map['level'] as String?);
    final loggerName = map['logger_name'] as String?;
    final latencyMs = (map['latency_ms'] as num?)?.toInt();

    String message = '';
    String? clientAddress;
    String? status = map['status'] as String?;

    if (map.containsKey('details') && map['details'] is String) {
      message = map['message'] as String? ?? '';
      try {
        final detailsMap = jsonDecode(map['details'] as String);
        if (detailsMap is Map<String, dynamic>) {
          clientAddress = detailsMap['client_ip']?.toString() ??
              detailsMap['client_mac']?.toString();
          status = detailsMap['status']?.toString() ?? status;
        }
      } catch (_) {}
    } else if (logType == 'dns') {
      final qType = map['query_type']?.toString() ?? '';
      final domain = map['domain']?.toString() ?? '';
      final answers = map['answers']?.toString() ?? '';
      final rcode = map['rcode']?.toString() ?? '';
      message =
          '$qType $domain => ${answers.isNotEmpty ? answers : rcode}'.trim();
      clientAddress = map['client_ip']?.toString();
      status = rcode.isNotEmpty ? rcode : status;
    } else if (logType == 'dhcp') {
      final msgType = map['message_type']?.toString() ?? '';
      final assignedIp = map['assigned_ip']?.toString() ?? '';
      final hostname = map['hostname']?.toString() ?? '';
      message =
          '$msgType $assignedIp ${hostname.isNotEmpty ? '($hostname)' : ''}'
              .trim();
      clientAddress =
          map['client_mac']?.toString() ?? map['client_ip']?.toString();
      status = msgType.isNotEmpty ? msgType : status;
    } else {
      message = map['message']?.toString() ?? '';
      clientAddress = map['isolate_id']?.toString();
    }

    return LogRecordItem(
      id: id,
      timestamp: timestamp,
      logType: logType,
      level: level,
      loggerName: loggerName,
      message:
          message.isNotEmpty ? message : (map['message']?.toString() ?? ''),
      clientAddress: clientAddress,
      status: status,
      latencyMs: latencyMs,
      rawFields: map,
    );
  }

  @override
  List<Object?> get props => [
        id,
        timestamp,
        logType,
        level,
        loggerName,
        message,
        clientAddress,
        status,
        latencyMs,
        rawFields,
      ];
}
