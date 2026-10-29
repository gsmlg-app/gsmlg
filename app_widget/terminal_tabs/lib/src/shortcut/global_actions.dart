import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_tabs/src/shortcut/intents.dart';

class GlobalActions extends StatelessWidget {
  const GlobalActions({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: {
        NewWindowIntent: CallbackAction<NewWindowIntent>(
          onInvoke: (NewWindowIntent intent) async {
            await context.read<WindowService?>()?.createWindow();
            return null;
          },
        ),
      },
      child: child,
    );
  }
}
