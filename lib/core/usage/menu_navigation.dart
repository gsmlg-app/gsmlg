import 'package:app_logging/app_logging.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'usage_tracker.dart';

/// Navigation helpers that record a `menu_tap` usage event, then navigate.
///
/// `target` is a route name or a literal location without path parameters.
extension MenuNavigation on BuildContext {
  void menuGoNamed(String name, {String? label}) {
    _recordMenuTap(
      this,
      name,
      () => GoRouter.of(this).namedLocation(name),
      label,
    );
    goNamed(name);
  }

  void menuGo(String location, {String? label}) {
    _recordMenuTap(this, location, () => location, label);
    go(location);
  }
}

void _recordMenuTap(
  BuildContext context,
  String target,
  String Function() location,
  String? label,
) {
  try {
    final tracker = UsageTracker.current;
    if (tracker == null) return;
    LogCapture.instance.usage(
      UsageEvent(
        ts: DateTime.now(),
        sessionId: tracker.sessionId,
        eventType: 'menu_tap',
        module: UsageTracker.moduleFor(Uri.parse(location())),
        target: target,
        sourceScreen: GoRouterState.of(context).name,
        payload: label == null ? null : {'label': label},
      ),
    );
  } catch (_) {
    // Usage logging must never block navigation.
  }
}
