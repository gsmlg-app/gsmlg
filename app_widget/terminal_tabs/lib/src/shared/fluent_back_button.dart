import 'package:flutter/material.dart';

class FluentBackButton extends StatelessWidget {
  const FluentBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(Icons.adaptive.arrow_back, size: 14.0),
      label: const SizedBox.shrink(),
      onPressed: () => _onPressed(context),
    );
  }

  void _onPressed(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
    } else {
      Navigator.of(context).maybePop();
    }
  }
}
