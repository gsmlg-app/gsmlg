import 'dart:convert';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart';
import 'package:logging/logging.dart' as logging;
import 'package:uuid/uuid.dart';

import 'rust/api/duckdb.dart' show SystemLogEntry, DnsLogEntry, DhcpLogEntry;

/// Result of routing a log record.
sealed class RoutedLog {
  const RoutedLog();
}

/// A routed system / general log entry.
class RoutedSystemLog extends RoutedLog {
  final SystemLogEntry entry;
  const RoutedSystemLog(this.entry);
}

/// A routed DNS query / response log entry.
class RoutedDnsLog extends RoutedLog {
  final DnsLogEntry entry;
  const RoutedDnsLog(this.entry);
}

/// A routed DHCP audit log entry.
class RoutedDhcpLog extends RoutedLog {
  final DhcpLogEntry entry;
  const RoutedDhcpLog(this.entry);
}

/// Utility for classifying and routing logs into domain-specific entries.
class LogRouter {
  static const _uuid = Uuid();

  static final _dnsQueryRegex = RegExp(
    r'^Query\s+([A-Z0-9]+)\s+([\w\.-]+)(?:\s+from\s+([\w\.:]+))?',
    caseSensitive: false,
  );

  static final _dnsResponseRegex = RegExp(
    r'^Response\s+([A-Z0-9]+)\s+([\w\.-]+)\s*=>\s*(.*?)\s*\((NOERROR|NXDOMAIN|SERVFAIL|REFUSED|FORMERR|NOTIMP)[,\s]+(\d+)ms\)',
    caseSensitive: false,
  );

  static final _dhcpRegex = RegExp(
    r'^(DHCP(?:DISCOVER|OFFER|REQUEST|ACK|NAK|DECLINE|RELEASE|INFORM))\s*(?:on\s+([\d\.]+))?\s*(?:to|from)?\s*([0-9a-fA-F:]{17}|[0-9a-fA-F-]{17})?(?:\s*(?:\(([\w\.-]+)\))?)?(?:\s*via\s+([\w\d]+))?',
    caseSensitive: false,
  );

  /// Route a [SerializableLogRecord] coming across isolate boundaries.
  static RoutedLog routeSerializable(SerializableLogRecord record) {
    final id = _uuid.v4();
    final loggerName = record.loggerName;
    final message = record.message;
    final context = record.context ?? const {};

    // 1. Check if it's DNS
    if (_isDns(loggerName, context)) {
      return RoutedDnsLog(
        _parseDns(id, record.time, loggerName, message, context),
      );
    }

    // 2. Check if it's DHCP
    if (_isDhcp(loggerName, context)) {
      return RoutedDhcpLog(
        _parseDhcp(id, record.time, loggerName, message, context),
      );
    }

    // 3. Default to system log
    return RoutedSystemLog(
      SystemLogEntry(
        id: id,
        timestampUs: PlatformInt64Util.from(record.time),
        level: record.levelName,
        loggerName: loggerName,
        message: message,
        isolateId: record.isolateId,
        error: record.error,
        stackTrace: record.stackTrace,
        metadata: context.isNotEmpty ? jsonEncode(context) : null,
      ),
    );
  }

  /// Route a standard [logging.LogRecord] from the root logger.
  static RoutedLog routeRoot(
    logging.LogRecord record, {
    String isolateId = 'main',
  }) {
    final id = _uuid.v4();
    final timeUs = record.time.microsecondsSinceEpoch;
    final loggerName = record.loggerName;
    final message = record.message;

    if (_isDns(loggerName, const {})) {
      return RoutedDnsLog(
        _parseDns(id, timeUs, loggerName, message, const {}),
      );
    }

    if (_isDhcp(loggerName, const {})) {
      return RoutedDhcpLog(
        _parseDhcp(id, timeUs, loggerName, message, const {}),
      );
    }

    return RoutedSystemLog(
      SystemLogEntry(
        id: id,
        timestampUs: PlatformInt64Util.from(timeUs),
        level: record.level.name,
        loggerName: loggerName,
        message: message,
        isolateId: isolateId,
        error: record.error?.toString(),
        stackTrace: record.stackTrace?.toString(),
        metadata: null,
      ),
    );
  }

  static bool _isDns(String loggerName, Map<String, dynamic> context) {
    if (context['protocol'] == 'DNS') return true;
    final lower = loggerName.toLowerCase();
    return lower.startsWith('dns') ||
        lower.contains('nameserver') ||
        lower.contains('zone');
  }

  static bool _isDhcp(String loggerName, Map<String, dynamic> context) {
    if (context['protocol'] == 'DHCP') return true;
    final lower = loggerName.toLowerCase();
    return lower.startsWith('dhcp');
  }

  static DnsLogEntry _parseDns(
    String id,
    int timestampUs,
    String loggerName,
    String message,
    Map<String, dynamic> context,
  ) {
    String? queryType = context['queryType'] as String?;
    String? domain = context['domain'] as String?;
    String? clientIp = (context['clientIp'] ?? context['sourceIp']) as String?;
    int? clientPort = context['clientPort'] as int?;
    String? rcode = context['rcode'] as String?;
    String? answers = context['answers']?.toString();
    int? latencyMs = context['latencyMs'] as int?;
    bool? cached = context['cached'] as bool?;
    String? upstream = context['upstream'] as String?;
    String? status = context['status'] as String?;
    String? protocol = context['protocol'] as String? ?? 'UDP';

    if (domain == null || rcode == null) {
      final respMatch = _dnsResponseRegex.firstMatch(message);
      if (respMatch != null) {
        queryType ??= respMatch.group(1);
        domain ??= respMatch.group(2);
        answers ??= respMatch.group(3)?.trim();
        rcode ??= respMatch.group(4);
        latencyMs ??= int.tryParse(respMatch.group(5) ?? '');
      } else {
        final queryMatch = _dnsQueryRegex.firstMatch(message);
        if (queryMatch != null) {
          queryType ??= queryMatch.group(1);
          domain ??= queryMatch.group(2);
          clientIp ??= queryMatch.group(3);
        }
      }
    }

    return DnsLogEntry(
      id: id,
      timestampUs: PlatformInt64Util.from(timestampUs),
      clientIp: clientIp,
      clientPort: clientPort,
      protocol: protocol,
      queryType: queryType,
      domain: domain?.toLowerCase(),
      rcode: rcode,
      answers: answers,
      latencyMs: latencyMs,
      cached: cached,
      upstream: upstream,
      status: status ??
          (rcode != null ? (rcode == 'NOERROR' ? 'SUCCESS' : rcode) : null),
    );
  }

  static DhcpLogEntry _parseDhcp(
    String id,
    int timestampUs,
    String loggerName,
    String message,
    Map<String, dynamic> context,
  ) {
    String? ipVersion = context['ipVersion'] as String? ??
        (loggerName.contains('v6') || loggerName.contains('V6')
            ? 'IPv6'
            : 'IPv4');
    String? messageType = context['messageType'] as String?;
    String? clientMac = context['clientMac'] as String?;
    String? hostname = context['hostname'] as String?;
    String? assignedIp = context['assignedIp'] as String?;
    int? leaseTimeSec = context['leaseTimeSec'] as int?;
    String? serverIp = context['serverIp'] as String?;
    String? interfaceName = context['interfaceName'] as String?;
    String? status = context['status'] as String?;

    if (messageType == null || assignedIp == null || clientMac == null) {
      final match = _dhcpRegex.firstMatch(message);
      if (match != null) {
        final fullType = match.group(1)?.toUpperCase() ?? '';
        messageType ??=
            fullType.startsWith('DHCP') ? fullType.substring(4) : fullType;
        assignedIp ??= match.group(2);
        clientMac ??= match.group(3);
        hostname ??= match.group(4);
        interfaceName ??= match.group(5);
      }
    }

    return DhcpLogEntry(
      id: id,
      timestampUs: PlatformInt64Util.from(timestampUs),
      ipVersion: ipVersion,
      messageType: messageType,
      clientMac: clientMac,
      hostname: hostname,
      assignedIp: assignedIp,
      leaseTimeSec: leaseTimeSec,
      serverIp: serverIp,
      interfaceName: interfaceName,
      status: status ?? (messageType == 'ACK' ? 'ASSIGNED' : messageType),
    );
  }
}
