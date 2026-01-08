import 'package:flutter/material.dart';

import '../grid_tile.dart';

/// Widget to display WHOIS lookup information in a styled card.
class WhoisInfo extends StatelessWidget {
  const WhoisInfo({
    super.key,
    required this.info,
  });

  /// The WHOIS information text to display.
  final String info;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: kDefaultGridGap / 2,
      margin: const EdgeInsets.only(bottom: kDefaultGridGap),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultGridGap),
        child: SelectableText.rich(
          TextSpan(
            children: [
              for (final line in info.split('\n'))
                TextSpan(
                  children: [
                    TextSpan(
                      text: line,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                    const TextSpan(text: '\n'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
