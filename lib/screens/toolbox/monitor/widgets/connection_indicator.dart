import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:monitor_bloc/monitor_bloc.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key, required this.status, this.size = 12});

  final ConnectionStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _color(context)),
    );
  }

  Color _color(BuildContext context) {
    final dmColors = Theme.of(context).extension<DmColorExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return switch (status) {
      ConnectionStatus.connected => dmColors.success,
      ConnectionStatus.connecting => dmColors.warning,
      ConnectionStatus.disconnected => colorScheme.onSurfaceVariant,
      ConnectionStatus.error => colorScheme.error,
    };
  }
}
