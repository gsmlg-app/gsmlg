import 'api_exchange_record.dart' show formatLogTimestamp;

class UsageEvent {
  const UsageEvent({
    required this.ts,
    required this.sessionId,
    required this.eventType,
    this.module,
    this.screenName,
    this.routePath,
    this.target,
    this.sourceScreen,
    this.durationMs,
    this.payload,
  });

  /// Inverse of [toJson].
  factory UsageEvent.fromJson(Map<String, Object?> json) => UsageEvent(
        ts: DateTime.parse(json['ts']! as String),
        sessionId: json['session_id']! as String,
        eventType: json['event_type']! as String,
        module: json['module'] as String?,
        screenName: json['screen_name'] as String?,
        routePath: json['route_path'] as String?,
        target: json['target'] as String?,
        sourceScreen: json['source_screen'] as String?,
        durationMs: (json['duration_ms'] as num?)?.toInt(),
        payload: (json['payload'] as Map?)?.cast<String, Object?>(),
      );

  final DateTime ts;
  final String sessionId;

  /// `session_start`, `session_end`, `screen_view` or `menu_tap`.
  final String eventType;
  final String? module, screenName, routePath, target, sourceScreen;
  final int? durationMs;
  final Map<String, Object?>? payload;

  Map<String, Object?> toJson() => {
        'ts': formatLogTimestamp(ts),
        'session_id': sessionId,
        'event_type': eventType,
        if (module != null) 'module': module,
        if (screenName != null) 'screen_name': screenName,
        if (routePath != null) 'route_path': routePath,
        if (target != null) 'target': target,
        if (sourceScreen != null) 'source_screen': sourceScreen,
        if (durationMs != null) 'duration_ms': durationMs,
        if (payload != null) 'payload': payload,
      };
}
