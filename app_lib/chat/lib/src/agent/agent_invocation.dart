import 'package:equatable/equatable.dart';

enum InvocationStatus {
  prepared,
  started,
  succeeded,
  failed,
  cancelled,
  unknown,
}

/// Represents an audited execution receipt for a tool call.
class ToolInvocationReceipt extends Equatable {
  const ToolInvocationReceipt({
    required this.runId,
    required this.callId,
    required this.invocationId,
    required this.toolName,
    required this.arguments,
    required this.status,
    this.result,
    this.isError = false,
    required this.timestamp,
  });

  final String runId;
  final String callId;
  final String invocationId;
  final String toolName;
  final String arguments;
  final InvocationStatus status;
  final dynamic result;
  final bool isError;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'runId': runId,
    'callId': callId,
    'invocationId': invocationId,
    'toolName': toolName,
    'arguments': arguments,
    'status': status.name,
    'result': result,
    'isError': isError,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ToolInvocationReceipt.fromJson(Map<String, dynamic> json) {
    return ToolInvocationReceipt(
      runId: json['runId'] as String,
      callId: json['callId'] as String,
      invocationId: json['invocationId'] as String? ?? json['callId'] as String,
      toolName: json['toolName'] as String,
      arguments: json['arguments'] as String? ?? '',
      status: InvocationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvocationStatus.unknown,
      ),
      result: json['result'],
      isError: json['isError'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    runId,
    callId,
    invocationId,
    toolName,
    arguments,
    status,
    result,
    isError,
    timestamp,
  ];
}
