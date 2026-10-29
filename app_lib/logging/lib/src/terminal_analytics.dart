import 'dart:async';

import 'package:logging/logging.dart' as logging;

/// Enumeration of session types for analytics tracking.
enum SessionType {
  /// Local shell session (PTY on desktop, Android/iOS specific on mobile)
  local,

  /// Remote SSH shell session
  ssh,

  /// Remote SFTP file manager session (planned)
  sftp,
}

/// Event types tracked by terminal analytics.
enum TerminalEvent {
  /// A new session was created
  sessionCreated,

  /// A session was closed
  sessionClosed,

  /// Fullscreen mode was toggled
  fullscreenToggled,
}

/// Analytics service for tracking terminal usage patterns.
///
/// This service tracks:
/// - Session creation by type (local, SSH, SFTP)
/// - Session closure
/// - Fullscreen toggle usage
///
/// Events are logged through the standard logging system and can be
/// forwarded to external analytics services if needed.
class TerminalAnalytics {
  static final TerminalAnalytics _instance = TerminalAnalytics._internal();
  factory TerminalAnalytics() => _instance;
  TerminalAnalytics._internal();

  final _logger = logging.Logger('TerminalAnalytics');

  final StreamController<AnalyticsEvent> _eventController =
      StreamController<AnalyticsEvent>.broadcast();

  /// Stream of analytics events for external consumption.
  Stream<AnalyticsEvent> get eventStream => _eventController.stream;

  /// Tracks a new session being created.
  ///
  /// [sessionType] - The type of session created (local, ssh, sftp).
  /// [metadata] - Optional metadata about the session.
  void trackSessionCreated(SessionType sessionType,
      {Map<String, dynamic>? metadata}) {
    final event = AnalyticsEvent(
      type: TerminalEvent.sessionCreated,
      properties: {
        'session_type': sessionType.name,
        ...?metadata,
      },
    );
    _logEvent(event);
    _eventController.add(event);
  }

  /// Tracks a session being closed.
  ///
  /// [sessionType] - The type of session closed.
  /// [durationMs] - Optional duration in milliseconds the session was active.
  void trackSessionClosed(SessionType sessionType, {int? durationMs}) {
    final event = AnalyticsEvent(
      type: TerminalEvent.sessionClosed,
      properties: {
        'session_type': sessionType.name,
        if (durationMs != null) 'duration_ms': durationMs,
      },
    );
    _logEvent(event);
    _eventController.add(event);
  }

  /// Tracks fullscreen mode being toggled.
  ///
  /// [isFullscreen] - The new fullscreen state.
  void trackFullscreenToggled(bool isFullscreen) {
    final event = AnalyticsEvent(
      type: TerminalEvent.fullscreenToggled,
      properties: {
        'is_fullscreen': isFullscreen,
      },
    );
    _logEvent(event);
    _eventController.add(event);
  }

  void _logEvent(AnalyticsEvent event) {
    _logger.info('${event.type.name}: ${event.properties}');
  }

  /// Disposes the analytics service and closes the event stream.
  void dispose() {
    _eventController.close();
  }
}

/// Represents an analytics event with type and properties.
class AnalyticsEvent {
  /// The type of event.
  final TerminalEvent type;

  /// Event properties/metadata.
  final Map<String, dynamic> properties;

  /// Timestamp when the event was created.
  final DateTime timestamp;

  AnalyticsEvent({
    required this.type,
    this.properties = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'AnalyticsEvent($type, $properties, $timestamp)';
}
