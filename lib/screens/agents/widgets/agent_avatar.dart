import 'package:app_agent/app_agent.dart';
import 'package:flutter/material.dart';

/// The agent's emoji avatar, or its initial when it has none.
class AgentAvatar extends StatelessWidget {
  const AgentAvatar({required this.agent, this.size = 40, super.key});

  final AgentDefinition agent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatar = agent.avatar?.trim() ?? '';
    final name = agent.name.trim();
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            avatar.isNotEmpty
                ? avatar
                : (name.isEmpty ? '?' : name.characters.first.toUpperCase()),
            style: TextStyle(
              fontSize: size * 0.5,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
