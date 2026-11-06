import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Sends one keyboard message to the peer engine.
typedef DuoKeyboardSend = void Function(Map<String, dynamic> message);

/// Message types exchanged by [DuoKeyboardRouter] and [DuoKeyboardProxy].
abstract final class DuoKeyboardMessages {
  /// Primary → secondary: client attached/shown, carries config and value.
  static const attach = 'ime_attach';

  /// Primary → secondary: primary editing value changed.
  static const state = 'ime_state';

  /// Primary → secondary: keyboard should hide (client still attached).
  static const hide = 'ime_hide';

  /// Primary → secondary: client detached.
  static const detach = 'ime_detach';

  /// Secondary → primary: IME produced a new editing value.
  static const update = 'ime_update';

  /// Secondary → primary: IME action key pressed.
  static const action = 'ime_action';

  static const all = {attach, state, hide, detach, update, action};
}

/// Encodes the subset of [TextInputConfiguration] the remote IME needs.
@visibleForTesting
Map<String, dynamic> encodeKeyboardConfig(TextInputConfiguration config) => {
  'inputType': config.inputType.toJson(),
  'inputAction': config.inputAction.name,
  'obscureText': config.obscureText,
  'autocorrect': config.autocorrect,
  'enableSuggestions': config.enableSuggestions,
  'textCapitalization': config.textCapitalization.name,
  'readOnly': config.readOnly,
};

/// Decodes [encodeKeyboardConfig] output; unknown values fall back to text.
@visibleForTesting
TextInputConfiguration decodeKeyboardConfig(Map<String, dynamic> json) {
  final type = json['inputType'] as Map<String, dynamic>? ?? const {};
  final name = type['name'] as String?;
  var inputType = TextInputType.text;
  if (name == TextInputType.number.toJson()['name']) {
    inputType = TextInputType.numberWithOptions(
      signed: type['signed'] as bool? ?? false,
      decimal: type['decimal'] as bool? ?? false,
    );
  } else {
    for (final candidate in TextInputType.values) {
      if (candidate.toJson()['name'] == name) {
        inputType = candidate;
        break;
      }
    }
  }
  return TextInputConfiguration(
    inputType: inputType,
    inputAction: _enumByName(
      TextInputAction.values,
      json['inputAction'],
      TextInputAction.done,
    ),
    obscureText: json['obscureText'] as bool? ?? false,
    autocorrect: json['autocorrect'] as bool? ?? true,
    enableSuggestions: json['enableSuggestions'] as bool? ?? true,
    textCapitalization: _enumByName(
      TextCapitalization.values,
      json['textCapitalization'],
      TextCapitalization.none,
    ),
    readOnly: json['readOnly'] as bool? ?? false,
  );
}

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

/// Primary-engine [TextInputControl] that moves the software keyboard to the
/// secondary display.
///
/// While installed, the platform control still owns the Android input
/// connection (so hardware keys keep working) but Flutter requests
/// [TextInputType.none] for it, which suppresses the keyboard on the primary
/// display. Every focused text client on the primary display is mirrored to
/// [DuoKeyboardProxy] on the secondary engine, whose IME edits are applied
/// back through [TextInput.updateEditingValue].
class DuoKeyboardRouter with TextInputControl {
  DuoKeyboardRouter(this._send);

  final DuoKeyboardSend _send;
  TextInputClient? _client;
  TextInputConfiguration _config = const TextInputConfiguration();
  TextEditingValue _value = TextEditingValue.empty;
  bool _visible = false;
  bool _installed = false;
  int _session = 0;
  int _controlGeneration = 0;

  bool get installed => _installed;

  void install() {
    if (_installed) return;
    _installed = true;
    TextInput.setInputControl(this);
    _refreshInputConnection();
  }

  void uninstall() {
    if (!_installed) return;
    final wasVisible = _visible;
    _installed = false;
    if (_visible) {
      _send({'type': DuoKeyboardMessages.detach, 'session': _session});
    }
    _visible = false;
    _client = null;
    TextInput.restorePlatformInputControl();
    _refreshInputConnection(showPlatform: wasVisible);
  }

  void _refreshInputConnection({bool showPlatform = false}) {
    final generation = ++_controlGeneration;
    // Switching controls does not attach the existing client or resend its
    // platform configuration. Replay Flutter's input-state request to reuse
    // the same connection, preserving focus, selection and composing text.
    ServicesBinding.instance.channelBuffers.push(
      SystemChannels.textInput.name,
      SystemChannels.textInput.codec.encodeMethodCall(
        const MethodCall('TextInputClient.requestExistingInputState'),
      ),
      (_) {
        if (generation != _controlGeneration) return;
        if (_installed) {
          show();
        } else if (showPlatform) {
          SystemChannels.textInput.invokeMethod<void>('TextInput.show');
        }
      },
    );
  }

  @override
  void attach(TextInputClient client, TextInputConfiguration configuration) {
    _client = client;
    _config = configuration;
    _value = client.currentTextEditingValue ?? TextEditingValue.empty;
    _session++;
    _visible = false;
  }

  @override
  void detach(TextInputClient client) {
    if (!identical(_client, client)) return;
    _client = null;
    if (_visible) {
      _send({'type': DuoKeyboardMessages.detach, 'session': _session});
    }
    _visible = false;
  }

  @override
  void updateConfig(TextInputConfiguration configuration) {
    _config = configuration;
    if (_visible) _sendAttach();
  }

  @override
  void setEditingState(TextEditingValue value) {
    if (value == _value) return;
    _value = value;
    if (_visible && _client != null) {
      _send({
        'type': DuoKeyboardMessages.state,
        'session': _session,
        'value': value.toJSON(),
      });
    }
  }

  @override
  void show() {
    if (_client == null) return;
    _visible = true;
    _sendAttach();
  }

  @override
  void hide() {
    if (!_visible) return;
    _visible = false;
    _send({'type': DuoKeyboardMessages.hide, 'session': _session});
  }

  void _sendAttach() {
    _send({
      'type': DuoKeyboardMessages.attach,
      'session': _session,
      'config': encodeKeyboardConfig(_config),
      'value': _value.toJSON(),
    });
  }

  /// Applies an [DuoKeyboardMessages.update] or [DuoKeyboardMessages.action]
  /// from the secondary engine to the attached primary client.
  void handleMessage(Map<String, dynamic> message) {
    final client = _client;
    if (client == null || message['session'] != _session) return;
    switch (message['type']) {
      case DuoKeyboardMessages.update:
        final value = TextEditingValue.fromJSON(
          (message['value'] as Map).cast<String, dynamic>(),
        );
        _value = value;
        TextInput.updateEditingValue(value);
      case DuoKeyboardMessages.action:
        client.performAction(
          _enumByName(
            TextInputAction.values,
            message['action'],
            TextInputAction.done,
          ),
        );
    }
  }
}

/// Moves Android window focus to the companion activity so that the IME is
/// allowed to appear on the secondary display.
class CompanionWindowFocus {
  CompanionWindowFocus({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('dev.duskmoon.duo/companion') {
    _channel.setMethodCallHandler(_onCall);
  }

  final MethodChannel _channel;
  bool _pendingShow = false;

  Future<void> _onCall(MethodCall call) async {
    if (call.method == 'windowFocusChanged' &&
        call.arguments == true &&
        _pendingShow) {
      _pendingShow = false;
      await _show();
    }
  }

  Future<void> _show() =>
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');

  /// Shows the keyboard for the current secondary text client, focusing the
  /// companion window first when another display currently owns focus.
  Future<void> requestKeyboard() async {
    _pendingShow = true;
    try {
      final focused = await _channel.invokeMethod<bool>('focusWindow');
      if (focused == true && _pendingShow) {
        _pendingShow = false;
        await _show();
      }
    } on MissingPluginException {
      _pendingShow = false;
    } on PlatformException {
      _pendingShow = false;
    }
  }

  void dispose() => _channel.setMethodCallHandler(null);
}

/// Secondary-engine IME client mirroring the primary's focused text field.
class DuoKeyboardProxy with TextInputClient, ChangeNotifier {
  DuoKeyboardProxy(this._send, {CompanionWindowFocus? window})
    // ignore: prefer_initializing_formals
    : _window = window {
    // Android IMEs may send Backspace as a key event instead of an editing
    // value. This proxy has no focused EditableText to handle that event.
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  final DuoKeyboardSend _send;
  final CompanionWindowFocus? _window;
  TextInputConnection? _connection;
  TextEditingValue _value = TextEditingValue.empty;
  TextInputConfiguration _config = const TextInputConfiguration();
  int? _session;

  /// Whether the secondary keyboard is currently typing into the primary.
  bool get active => _connection?.attached == true;

  void handleMessage(Map<String, dynamic> message) {
    final session = message['session'] as int?;
    switch (message['type']) {
      case DuoKeyboardMessages.attach:
        _session = session;
        _value = TextEditingValue.fromJSON(
          (message['value'] as Map).cast<String, dynamic>(),
        );
        _config = decodeKeyboardConfig(
          (message['config'] as Map).cast<String, dynamic>(),
        );
        _open();
      case DuoKeyboardMessages.state:
        if (session != _session) return;
        _value = TextEditingValue.fromJSON(
          (message['value'] as Map).cast<String, dynamic>(),
        );
        if (active) _connection!.setEditingState(_value);
      case DuoKeyboardMessages.hide || DuoKeyboardMessages.detach:
        if (session != _session) return;
        close();
    }
  }

  void _open() {
    if (active) {
      _connection!.updateConfig(_config);
    } else {
      _connection = TextInput.attach(this, _config);
    }
    _connection!
      ..setEditingState(_value)
      ..show();
    _window?.requestKeyboard();
    notifyListeners();
  }

  void close() {
    final wasActive = active;
    if (wasActive) _connection!.close();
    _connection = null;
    if (wasActive) notifyListeners();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (!active ||
        _config.readOnly ||
        event.logicalKey != LogicalKeyboardKey.backspace) {
      return false;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return true;

    final selection = _value.selection;
    if (!selection.isValid) return true;
    final start = selection.isCollapsed
        ? CharacterBoundary(
            _value.text,
          ).getLeadingTextBoundaryAt(selection.start - 1)
        : selection.start;
    if (start == null || start == selection.end) return true;

    final value = _value
        .replaced(TextRange(start: start, end: selection.end), '')
        .copyWith(selection: TextSelection.collapsed(offset: start));
    _connection!.setEditingState(value);
    updateEditingValue(value);
    return true;
  }

  @override
  TextEditingValue? get currentTextEditingValue => _value;

  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  void updateEditingValue(TextEditingValue value) {
    if (value == _value) return;
    _value = value;
    _send({
      'type': DuoKeyboardMessages.update,
      'session': _session,
      'value': value.toJSON(),
    });
  }

  @override
  void performAction(TextInputAction action) {
    _send({
      'type': DuoKeyboardMessages.action,
      'session': _session,
      'action': action.name,
    });
  }

  @override
  void connectionClosed() {
    _connection = null;
    notifyListeners();
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @override
  void insertTextPlaceholder(Size size) {}

  @override
  void removeTextPlaceholder() {}

  @override
  void didChangeInputControl(
    TextInputControl? oldControl,
    TextInputControl? newControl,
  ) {}

  @override
  void performSelector(String selectorName) {}

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    close();
    super.dispose();
  }
}
