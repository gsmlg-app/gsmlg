part of 'bloc.dart';

/// Lifecycle status of a single VNC remote desktop session.
enum VncSessionStatus {
  idle,
  connecting,
  authRequired,
  connected,
  disconnected,
  error,
}

/// Immutable state for [VncSessionBloc].
@immutable
class VncSessionState extends Equatable {
  const VncSessionState({
    this.status = VncSessionStatus.idle,
    this.config,
    this.desktopInfo,
    this.width = 0,
    this.height = 0,
    this.screens = const [],
    this.activeRegion,
    this.serverSideDisplaySwitch = false,
    this.activeDisplayId,
    this.isSwitchingDisplay = false,
    this.viewOnly = false,
    this.authSecurityType,
    this.authRequiresUsername = false,
    this.cursor,
    this.lastRemoteClipboard,
    this.clipboardSeq = 0,
    this.error,
    this.disconnectReason,
  });

  final VncSessionStatus status;
  final VncConnectionConfig? config;
  final VncDesktopInfo? desktopInfo;
  final int width;
  final int height;
  final List<VncScreenInfo> screens;
  final VncScreenInfo? activeRegion;
  final bool serverSideDisplaySwitch;
  final int? activeDisplayId;
  final bool isSwitchingDisplay;
  final bool viewOnly;
  final int? authSecurityType;
  final bool authRequiresUsername;
  final VncCursorData? cursor;
  final String? lastRemoteClipboard;
  final int clipboardSeq;
  final VncException? error;
  final String? disconnectReason;

  VncSessionState copyWith({
    VncSessionStatus? status,
    VncConnectionConfig? config,
    VncDesktopInfo? desktopInfo,
    int? width,
    int? height,
    List<VncScreenInfo>? screens,
    VncScreenInfo? activeRegion,
    bool? serverSideDisplaySwitch,
    int? activeDisplayId,
    bool? isSwitchingDisplay,
    bool? viewOnly,
    int? authSecurityType,
    bool? authRequiresUsername,
    VncCursorData? cursor,
    String? lastRemoteClipboard,
    int? clipboardSeq,
    VncException? error,
    String? disconnectReason,
    bool clearDesktopInfo = false,
    bool clearActiveRegion = false,
    bool clearActiveDisplayId = false,
    bool clearError = false,
    bool clearAuth = false,
    bool clearDisconnectReason = false,
    bool clearCursor = false,
  }) {
    return VncSessionState(
      status: status ?? this.status,
      config: config ?? this.config,
      desktopInfo: clearDesktopInfo ? null : (desktopInfo ?? this.desktopInfo),
      width: width ?? this.width,
      height: height ?? this.height,
      screens: screens ?? this.screens,
      activeRegion: clearActiveRegion
          ? null
          : (activeRegion ?? this.activeRegion),
      serverSideDisplaySwitch:
          serverSideDisplaySwitch ?? this.serverSideDisplaySwitch,
      activeDisplayId: clearActiveDisplayId
          ? null
          : (activeDisplayId ?? this.activeDisplayId),
      isSwitchingDisplay: isSwitchingDisplay ?? this.isSwitchingDisplay,
      viewOnly: viewOnly ?? this.viewOnly,
      authSecurityType: clearAuth
          ? null
          : (authSecurityType ?? this.authSecurityType),
      authRequiresUsername: clearAuth
          ? false
          : (authRequiresUsername ?? this.authRequiresUsername),
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      lastRemoteClipboard: lastRemoteClipboard ?? this.lastRemoteClipboard,
      clipboardSeq: clipboardSeq ?? this.clipboardSeq,
      error: clearError ? null : (error ?? this.error),
      disconnectReason: clearDisconnectReason
          ? null
          : (disconnectReason ?? this.disconnectReason),
    );
  }

  @override
  List<Object?> get props => [
    status,
    config,
    desktopInfo,
    width,
    height,
    screens,
    activeRegion,
    serverSideDisplaySwitch,
    activeDisplayId,
    isSwitchingDisplay,
    viewOnly,
    authSecurityType,
    authRequiresUsername,
    cursor,
    lastRemoteClipboard,
    clipboardSeq,
    error,
    disconnectReason,
  ];
}
