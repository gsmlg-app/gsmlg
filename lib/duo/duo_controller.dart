import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:app_chat/app_chat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const secondaryRouteName = 'secondaryDisplayMain';

/// Represents an agent option for dual-screen chat coordination.
class DuoChatAgent {
  const DuoChatAgent({required this.id, required this.name});
  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory DuoChatAgent.fromJson(Map<String, dynamic> json) =>
      DuoChatAgent(id: json['id'] as String, name: json['name'] as String);
}

/// Serializable attachment data for cross-isolate transfer.
class DuoChatAttachmentData {
  const DuoChatAttachmentData({
    required this.id,
    required this.name,
    this.sizeBytes,
    this.mimeType,
    this.base64Bytes,
  });

  final String id;
  final String name;
  final int? sizeBytes;
  final String? mimeType;
  final String? base64Bytes;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (sizeBytes != null) 'sizeBytes': sizeBytes,
    if (mimeType != null) 'mimeType': mimeType,
    if (base64Bytes != null) 'base64Bytes': base64Bytes,
  };

  factory DuoChatAttachmentData.fromJson(Map<String, dynamic> json) =>
      DuoChatAttachmentData(
        id: json['id'] as String,
        name: json['name'] as String,
        sizeBytes: json['sizeBytes'] as int?,
        mimeType: json['mimeType'] as String?,
        base64Bytes: json['base64Bytes'] as String?,
      );

  ChatAttachment toChatAttachment() {
    return ChatAttachment(
      id: id,
      name: name,
      sizeBytes: sizeBytes,
      mimeType: mimeType,
      bytes: base64Bytes != null ? base64Decode(base64Bytes!) : null,
    );
  }

  static DuoChatAttachmentData fromChatAttachment(ChatAttachment attachment) {
    return DuoChatAttachmentData(
      id: attachment.id,
      name: attachment.name,
      sizeBytes: attachment.sizeBytes,
      mimeType: attachment.mimeType,
      base64Bytes:
          attachment.bytes != null ? base64Encode(attachment.bytes!) : null,
    );
  }
}

/// Chat state synchronized from Primary Display to Secondary Display.
class DuoChatState {
  const DuoChatState({
    this.isStreaming = false,
    this.canSend = true,
    this.modelName,
    this.activeAgentName,
    this.activeAgentId,
    this.agents = const [],
    this.supportsImage = false,
    this.supportsAudio = false,
    this.historyTokens = 0,
  });

  final bool isStreaming;
  final bool canSend;
  final String? modelName;
  final String? activeAgentName;
  final String? activeAgentId;
  final List<DuoChatAgent> agents;
  final bool supportsImage;
  final bool supportsAudio;
  final int historyTokens;

  Map<String, dynamic> toJson() => {
    'isStreaming': isStreaming,
    'canSend': canSend,
    if (modelName != null) 'modelName': modelName,
    if (activeAgentName != null) 'activeAgentName': activeAgentName,
    if (activeAgentId != null) 'activeAgentId': activeAgentId,
    'agents': agents.map((a) => a.toJson()).toList(),
    'supportsImage': supportsImage,
    'supportsAudio': supportsAudio,
    'historyTokens': historyTokens,
  };

  factory DuoChatState.fromJson(Map<String, dynamic> json) => DuoChatState(
    isStreaming: json['isStreaming'] as bool? ?? false,
    canSend: json['canSend'] as bool? ?? true,
    modelName: json['modelName'] as String?,
    activeAgentName: json['activeAgentName'] as String?,
    activeAgentId: json['activeAgentId'] as String?,
    agents:
        (json['agents'] as List<dynamic>?)
            ?.map((a) => DuoChatAgent.fromJson(a as Map<String, dynamic>))
            .toList() ??
        const [],
    supportsImage: json['supportsImage'] as bool? ?? false,
    supportsAudio: json['supportsAudio'] as bool? ?? false,
    historyTokens: json['historyTokens'] as int? ?? 0,
  );
}

/// Platform channel interface for Android secondary presentation displays.
abstract interface class DuoDisplayPlatform {
  Stream<void> get changes;
  Future<List<int>> presentationDisplays();
  Future<bool> show(int displayId);
  Future<bool> hide(int displayId);
}

class AndroidDuoDisplayPlatform implements DuoDisplayPlatform {
  static const _methods = MethodChannel('dev.duskmoon.duo/displays');
  static const _events = EventChannel('dev.duskmoon.duo/display_changes');

  @override
  Stream<void> get changes => _events.receiveBroadcastStream().map((_) {});

  @override
  Future<List<int>> presentationDisplays() async {
    final displays = await _methods.invokeListMethod<int>('listDisplays');
    return [
      for (final display in displays ?? <int>[])
        if (display > 0) display,
    ];
  }

  @override
  Future<bool> show(int displayId) async =>
      displayId > 0 &&
      await _methods.invokeMethod<bool>('show', {'displayId': displayId}) ==
          true;

  @override
  Future<bool> hide(int displayId) async =>
      await _methods.invokeMethod<bool>('hide', {'displayId': displayId}) ==
      true;
}

class SingleDisplayPlatform implements DuoDisplayPlatform {
  const SingleDisplayPlatform();
  @override
  Stream<void> get changes => const Stream.empty();
  @override
  Future<List<int>> presentationDisplays() async => [];
  @override
  Future<bool> show(int displayId) async => false;
  @override
  Future<bool> hide(int displayId) async => true;
}

DuoDisplayPlatform defaultDisplayPlatform() =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? AndroidDuoDisplayPlatform()
        : const SingleDisplayPlatform();

/// Inter-isolate message bridge between Primary and Secondary Flutter engines.
abstract interface class DuoBridge {
  Stream<Object?> get messages;
  void start();
  void send(String message);
  void dispose();
}

class SingleDisplayBridge implements DuoBridge {
  const SingleDisplayBridge();
  @override
  Stream<Object?> get messages => const Stream.empty();
  @override
  void start() {}
  @override
  void send(String message) {}
  @override
  void dispose() {}
}

class IsolateDuoBridge implements DuoBridge {
  IsolateDuoBridge({required bool secondary})
      : _ownName = secondary ? _secondaryName : _primaryName,
        _peerName = secondary ? _primaryName : _secondaryName;

  static const _primaryName = 'org.gsmlg.duo.primary';
  static const _secondaryName = 'org.gsmlg.duo.secondary';
  final String _ownName;
  final String _peerName;
  final ReceivePort _port = ReceivePort();

  @override
  Stream<Object?> get messages => _port;

  @override
  void start() {
    IsolateNameServer.removePortNameMapping(_ownName);
    if (!IsolateNameServer.registerPortWithName(_port.sendPort, _ownName)) {
      throw StateError('Cannot register duo bridge port for $_ownName');
    }
  }

  @override
  void send(String message) =>
      IsolateNameServer.lookupPortByName(_peerName)?.send(message);

  @override
  void dispose() {
    if (IsolateNameServer.lookupPortByName(_ownName) == _port.sendPort) {
      IsolateNameServer.removePortNameMapping(_ownName);
    }
    _port.close();
  }
}

DuoBridge defaultBridge({required bool secondary}) =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? IsolateDuoBridge(secondary: secondary)
        : const SingleDisplayBridge();

/// Manages dual-screen coordination, heartbeat handshake, and intent routing.
class DuoDisplayManager extends ChangeNotifier {
  DuoDisplayManager({
    required this.secondary,
    required this.platform,
    required this.bridge,
  }) {
    if (!secondary) {
      instance = this;
    }
  }

  static DuoDisplayManager? instance;

  final bool secondary;
  final DuoDisplayPlatform platform;
  final DuoBridge bridge;

  bool _connected = false;
  bool get connected => _connected;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  String _currentRoute = '/';
  String get currentRoute => _currentRoute;

  bool _isDark = false;
  bool get isDark => _isDark;

  int? _activeDisplayId;
  int? get activeDisplayId => _activeDisplayId;

  StreamSubscription<void>? _platformSub;
  StreamSubscription<Object?>? _bridgeSub;
  Timer? _heartbeatTimer;
  DateTime? _lastPeerSeen;

  void Function(int index)? onSelectTab;
  void Function(String routeName)? onNavigateRoute;
  VoidCallback? onToggleTheme;
  void Function(bool connected)? onConnectionChanged;

  /// Text relay callbacks
  void Function(String text)? onTextInput;
  void Function(String text)? onTextSubmit;
  void Function(String text)? onFallbackTextSubmit;
  void Function(String text)? onTextSync;
  VoidCallback? onRequestFocus;
  VoidCallback? onEscKey;

  /// Chat relay callbacks (Primary engine)
  void Function(String text, {List<ChatAttachment>? attachments})? onChatSend;
  VoidCallback? onChatStop;
  void Function(String agentId)? onChatSelectAgent;

  DuoChatState? _chatState;
  DuoChatState? get chatState => _chatState;

  void start() {
    bridge.start();
    _bridgeSub = bridge.messages.listen(_handleBridgeMessage);

    if (secondary) {
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        bridge.send(jsonEncode({'type': 'hello'}));
      });
    } else {
      _platformSub = platform.changes.listen((_) => _checkDisplays());
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (_connected &&
            _lastPeerSeen != null &&
            DateTime.now().difference(_lastPeerSeen!) >
                const Duration(seconds: 6)) {
          _setConnected(false);
        }
      });
      _checkDisplays();
    }
  }

  Future<void> _checkDisplays() async {
    if (secondary) return;
    try {
      final displays = await platform.presentationDisplays();
      if (displays.isNotEmpty) {
        final target = displays.first;
        if (_activeDisplayId != target) {
          _activeDisplayId = target;
          await platform.show(target);
        }
      } else if (_activeDisplayId != null) {
        final previous = _activeDisplayId!;
        _activeDisplayId = null;
        await platform.hide(previous);
        _setConnected(false);
      }
    } catch (_) {}
  }

  void updatePrimaryState({
    required int selectedIndex,
    required String currentRoute,
    required bool isDark,
  }) {
    if (secondary) return;
    _selectedIndex = selectedIndex;
    _currentRoute = currentRoute;
    _isDark = isDark;
    notifyListeners();
    if (_connected) {
      bridge.send(jsonEncode({
        'type': 'snapshot',
        'selectedIndex': _selectedIndex,
        'currentRoute': _currentRoute,
        'isDark': _isDark,
        if (_chatState != null) 'chatState': _chatState!.toJson(),
      }));
    }
  }

  void updateChatState(DuoChatState? state) {
    if (secondary) return;
    _chatState = state;
    notifyListeners();
    if (_connected) {
      bridge.send(jsonEncode({
        'type': 'chat_state',
        'state': state?.toJson(),
      }));
    }
  }

  void sendSecondaryIntent({
    required String action,
    int? index,
    String? route,
  }) {
    if (!secondary) return;
    bridge.send(jsonEncode({
      'type': 'intent',
      'action': action,
      'index': ?index,
      'route': ?route,
    }));
  }

  void sendTextInput(String text) {
    if (!secondary) return;
    bridge.send(jsonEncode({
      'type': 'text_input',
      'text': text,
    }));
  }

  void sendTextSubmit(String text) {
    if (!secondary) return;
    bridge.send(jsonEncode({
      'type': 'text_submit',
      'text': text,
    }));
  }

  void sendChatSend(String text, {List<ChatAttachment>? attachments}) {
    if (!secondary) return;
    bridge.send(jsonEncode({
      'type': 'chat_send',
      'text': text,
      if (attachments != null)
        'attachments': attachments
            .map((a) => DuoChatAttachmentData.fromChatAttachment(a).toJson())
            .toList(),
    }));
  }

  void sendChatStop() {
    if (!secondary) return;
    bridge.send(jsonEncode({
      'type': 'chat_stop',
    }));
  }

  void sendChatSelectAgent(String agentId) {
    if (!secondary) return;
    bridge.send(jsonEncode({
      'type': 'chat_select_agent',
      'agentId': agentId,
    }));
  }

  void syncPrimaryText(String text) {
    if (secondary) return;
    if (_connected) {
      bridge.send(jsonEncode({
        'type': 'text_sync',
        'text': text,
      }));
    }
  }

  void requestSecondaryFocus() {
    if (secondary) return;
    if (_connected) {
      bridge.send(jsonEncode({
        'type': 'request_focus',
      }));
    }
  }

  void _handleBridgeMessage(Object? raw) {
    if (raw is! String) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final type = map['type'] as String?;
      _lastPeerSeen = DateTime.now();

      if (secondary) {
        if (type == 'welcome' || type == 'snapshot') {
          _setConnected(true);
          if (map.containsKey('selectedIndex')) {
            _selectedIndex = map['selectedIndex'] as int;
          }
          if (map.containsKey('currentRoute')) {
            _currentRoute = map['currentRoute'] as String;
          }
          if (map.containsKey('isDark')) {
            _isDark = map['isDark'] as bool;
          }
          if (map.containsKey('chatState') && map['chatState'] != null) {
            _chatState = DuoChatState.fromJson(
              map['chatState'] as Map<String, dynamic>,
            );
          }
          notifyListeners();
          if (type == 'welcome') {
            bridge.send(jsonEncode({'type': 'ready'}));
          }
        } else if (type == 'chat_state') {
          _chatState = map['state'] != null
              ? DuoChatState.fromJson(map['state'] as Map<String, dynamic>)
              : null;
          notifyListeners();
        } else if (type == 'text_sync' && map.containsKey('text')) {
          onTextSync?.call(map['text'] as String);
        } else if (type == 'request_focus') {
          onRequestFocus?.call();
        }
      } else {
        if (type == 'hello') {
          _setConnected(true);
          bridge.send(jsonEncode({
            'type': 'welcome',
            'selectedIndex': _selectedIndex,
            'currentRoute': _currentRoute,
            'isDark': _isDark,
            if (_chatState != null) 'chatState': _chatState!.toJson(),
          }));
        } else if (type == 'ready') {
          _setConnected(true);
        } else if (type == 'intent') {
          final action = map['action'] as String?;
          if (action == 'select' && map.containsKey('index')) {
            final idx = map['index'] as int;
            _selectedIndex = idx;
            notifyListeners();
            onSelectTab?.call(idx);
          } else if (action == 'route' && map.containsKey('route')) {
            onNavigateRoute?.call(map['route'] as String);
          } else if (action == 'toggleTheme') {
            onToggleTheme?.call();
          } else if (action == 'esc') {
            onEscKey?.call();
          }
        } else if (type == 'text_input' && map.containsKey('text')) {
          onTextInput?.call(map['text'] as String);
        } else if (type == 'text_submit' && map.containsKey('text')) {
          final text = map['text'] as String;
          if (onTextSubmit != null) {
            onTextSubmit!(text);
          } else {
            onFallbackTextSubmit?.call(text);
          }
        } else if (type == 'chat_send') {
          final text = map['text'] as String? ?? '';
          final rawAttachments = map['attachments'] as List<dynamic>?;
          final attachments = rawAttachments
              ?.map(
                (a) => DuoChatAttachmentData.fromJson(
                  a as Map<String, dynamic>,
                ).toChatAttachment(),
              )
              .toList();
          if (onChatSend != null) {
            onChatSend!(text, attachments: attachments);
          } else if (onTextSubmit != null) {
            onTextSubmit!(text);
          } else {
            onFallbackTextSubmit?.call(text);
          }
        } else if (type == 'chat_stop') {
          onChatStop?.call();
        } else if (type == 'chat_select_agent' && map.containsKey('agentId')) {
          onChatSelectAgent?.call(map['agentId'] as String);
        }
      }
    } catch (_) {}
  }

  void _setConnected(bool value) {
    if (_connected != value) {
      _connected = value;
      notifyListeners();
      onConnectionChanged?.call(value);
    }
  }

  @override
  void dispose() {
    if (instance == this) instance = null;
    _platformSub?.cancel();
    _bridgeSub?.cancel();
    _heartbeatTimer?.cancel();
    if (!secondary && _activeDisplayId != null) {
      platform.hide(_activeDisplayId!);
    }
    bridge.dispose();
    super.dispose();
  }
}
