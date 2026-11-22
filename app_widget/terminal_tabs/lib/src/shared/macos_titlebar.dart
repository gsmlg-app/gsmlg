import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

const kMacosTitlebarHeight = 28.0;

class MacosTitlebar extends StatefulWidget {
  const MacosTitlebar({super.key, required this.color, this.window});

  final Color color;

  /// The window whose full screen state hides the bar; defaults to the app's
  /// current window.
  final Window? window;

  @override
  State<MacosTitlebar> createState() => _MacosTitlebarState();
}

class _MacosTitlebarState extends State<MacosTitlebar> {
  var fullScreen = false;
  Window? _window;
  ListenerId? _listenerId;

  void _onWindowEvent(WindowEvent event) {
    if (!mounted) return;
    switch (event) {
      case WindowEnteredFullScreenEvent():
        setState(() => fullScreen = true);
      case WindowExitedFullScreenEvent():
        setState(() => fullScreen = false);
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _window = widget.window ?? WindowManager.instance.getCurrent();
    _listenerId = _window?.addListener(_onWindowEvent);
  }

  @override
  void dispose() {
    final listenerId = _listenerId;
    if (listenerId != null) _window?.removeListener(listenerId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fullScreen ? 0 : kMacosTitlebarHeight,
      color: widget.color,
    );
  }
}
