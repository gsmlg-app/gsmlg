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
      decoration: BoxDecoration(shape: BoxShape.circle, color: _color),
    );
  }

  Color get _color => switch (status) {
    ConnectionStatus.connected => Colors.green,
    ConnectionStatus.connecting => Colors.orange,
    ConnectionStatus.disconnected => Colors.grey,
    ConnectionStatus.error => Colors.red,
  };
}
