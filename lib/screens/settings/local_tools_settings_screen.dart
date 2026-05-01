// ignore_for_file: depend_on_referenced_packages

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:duskmoon_settings/duskmoon_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/settings/settings_screen.dart';

class LocalToolsSettingsScreen extends StatelessWidget {
  static const name = 'LocalTools';
  static const path = 'local-tools';

  const LocalToolsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = context.read<ToolExecutor>().toolDefinitions;
    final groups = <_ToolGroup>[
      _ToolGroup(
        title: 'Lookup Tools',
        icon: Icons.search,
        tools: tools
            .where(
              (tool) => const {
                'whois_lookup',
                'ip_geolocation',
                'web_fetch',
                'web_search',
              }.contains(tool.name),
            )
            .toList(growable: false),
      ),
      _ToolGroup(
        title: 'Domain Tools',
        icon: Icons.dns,
        tools: tools
            .where((tool) => tool.name.startsWith('domain_'))
            .toList(growable: false),
      ),
      _ToolGroup(
        title: 'Vultr Tools',
        icon: Icons.cloud_queue,
        tools: tools
            .where((tool) => tool.name.startsWith('vultr_'))
            .toList(growable: false),
      ),
    ].where((group) => group.tools.isNotEmpty).toList(growable: false);

    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreen.name),
        context,
      ),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      destinations: Destinations.navs(context),
      body: (context) {
        return SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              const SliverAppBar(title: Text('Local Tools')),
              SliverFillRemaining(
                child: SettingsList(
                  sections: [
                    SettingsSection(
                      title: const Text('Available'),
                      tiles: [
                        SettingsTile(
                          leading: const Icon(Icons.build_circle_outlined),
                          title: Text(
                            '${tools.length} local tool${tools.length == 1 ? '' : 's'}',
                          ),
                          description: const Text(
                            'These tools are available to local and remote chat models when function calling is enabled.',
                          ),
                        ),
                      ],
                    ),
                    for (final group in groups)
                      SettingsSection(
                        title: Text(group.title),
                        tiles: [
                          for (final tool in group.tools)
                            SettingsTile(
                              leading: Icon(group.icon),
                              title: Text(_toolTitle(tool.name)),
                              value: Text(tool.name),
                              description: Text(
                                _toolDescription(
                                  tool.description,
                                  tool.parameters,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      smallSecondaryBody: DmAdaptiveScaffold.emptyBuilder,
    );
  }

  static String _toolTitle(String name) {
    return name
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static String _toolDescription(
    String description,
    Map<String, dynamic> parameters,
  ) {
    final required = parameters['required'];
    final requiredNames = required is List<dynamic>
        ? required.whereType<String>().toList(growable: false)
        : const <String>[];
    if (requiredNames.isEmpty) return description;
    return '$description Required: ${requiredNames.join(', ')}.';
  }
}

class _ToolGroup {
  const _ToolGroup({
    required this.title,
    required this.icon,
    required this.tools,
  });

  final String title;
  final IconData icon;
  final List<gemma.Tool> tools;
}
