import 'package:flutter/material.dart';

import 'glass_container.dart';

/// A widget that observes app lifecycle changes and applies a glass effect
/// when the app becomes inactive.
///
/// This can be used for privacy protection or visual feedback when the app
/// is backgrounded or loses focus.
@immutable
class LifecycleManager extends StatefulWidget {
  /// The child widget to manage.
  final Widget child;

  /// Whether to apply the glass effect when the app is inactive.
  /// Defaults to true.
  final bool applyGlassOnInactive;

  /// The blur amount for the glass effect.
  /// Defaults to 5.0.
  final double blur;

  /// The opacity of the glass overlay.
  /// Defaults to 0.5.
  final double opacity;

  const LifecycleManager({
    super.key,
    required this.child,
    this.applyGlassOnInactive = true,
    this.blur = 5.0,
    this.opacity = 0.5,
  });

  @override
  State<LifecycleManager> createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends State<LifecycleManager>
    with WidgetsBindingObserver {
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint('LifecycleManager<AppLifecycleState<$state>>');
    setState(() {
      _lastLifecycleState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.applyGlassOnInactive &&
        _lastLifecycleState == AppLifecycleState.inactive) {
      return GlassContainer(
        blur: widget.blur,
        opacity: widget.opacity,
        child: widget.child,
      );
    }
    return widget.child;
  }
}
