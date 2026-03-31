import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_chat/app_chat.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/home/home_screen.dart';
import 'package:settings_ui/settings_ui.dart';

class ChatSettingsScreen extends StatefulWidget {
  static const name = 'ChatSettings';
  static const path = 'settings';

  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(HomeScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Chat Settings'),
        ),
        body: BlocBuilder<ChatSettingsBloc, ChatSettingsState>(
          builder: (context, state) {
            return SettingsList(
            sections: [
              SettingsSection(
                title: const Text('Model'),
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.memory),
                    title: const Text('Model Type'),
                    value: Text(state.config.modelDisplayName),
                    onPressed: (_) => _showModelTypePicker(context, state.config),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.speed),
                    title: const Text('Backend'),
                    value: Text(state.config.backend == GemmaBackend.gpu
                        ? 'GPU (Recommended)'
                        : 'CPU'),
                    onPressed: (_) => _showBackendPicker(context, state.config),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Generation'),
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.format_list_numbered),
                    title: const Text('Max Tokens'),
                    value: Text('${state.config.maxTokens}'),
                    onPressed: (_) =>
                        _showMaxTokensDialog(context, state.config),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.thermostat),
                    title: const Text('Temperature'),
                    value: Text(state.config.temperature.toStringAsFixed(2)),
                    description: const Text('Higher = more creative'),
                    onPressed: (_) =>
                        _showTemperatureDialog(context, state.config),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.filter_list),
                    title: const Text('Top-K'),
                    value: Text('${state.config.topK}'),
                    description: const Text('Sampling diversity'),
                    onPressed: (_) => _showTopKDialog(context, state.config),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('System Prompt'),
                tiles: [
                  SettingsTile.navigation(
                    leading: const Icon(Icons.edit_note),
                    title: const Text('Default System Prompt'),
                    value: Text(
                      state.defaultSystemPrompt?.isNotEmpty == true
                          ? '${state.defaultSystemPrompt!.substring(0, state.defaultSystemPrompt!.length.clamp(0, 30))}...'
                          : 'Not set',
                    ),
                    onPressed: (_) =>
                        _showSystemPromptDialog(context, state.defaultSystemPrompt),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Actions'),
                tiles: [
                  SettingsTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Reset to Defaults'),
                    onPressed: (_) => _confirmReset(context),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  void _showModelTypePicker(BuildContext context, ModelConfig config) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Radio<GemmaModelType>(
              value: GemmaModelType.gemma2bIt,
              groupValue: config.modelType,
              onChanged: (v) => _updateModelType(context, sheetContext, v!),
            ),
            title: const Text('Gemma 2B-IT'),
            subtitle: const Text('Recommended for most devices'),
            onTap: () => _updateModelType(
                context, sheetContext, GemmaModelType.gemma2bIt),
          ),
          ListTile(
            leading: Radio<GemmaModelType>(
              value: GemmaModelType.gemma7bIt,
              groupValue: config.modelType,
              onChanged: (v) => _updateModelType(context, sheetContext, v!),
            ),
            title: const Text('Gemma 7B-IT'),
            subtitle: const Text('Better quality, requires more RAM'),
            onTap: () => _updateModelType(
                context, sheetContext, GemmaModelType.gemma7bIt),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _updateModelType(
      BuildContext context, BuildContext sheetContext, GemmaModelType type) {
    final currentConfig = context.read<ChatSettingsBloc>().state.config;
    context.read<ChatSettingsBloc>().add(
          ChatSettingsUpdateConfig(config: currentConfig.copyWith(modelType: type)),
        );
    Navigator.pop(sheetContext);
  }

  void _showBackendPicker(BuildContext context, ModelConfig config) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Radio<GemmaBackend>(
              value: GemmaBackend.gpu,
              groupValue: config.backend,
              onChanged: (v) => _updateBackend(context, sheetContext, v!),
            ),
            title: const Text('GPU'),
            subtitle: const Text('Faster, recommended'),
            onTap: () =>
                _updateBackend(context, sheetContext, GemmaBackend.gpu),
          ),
          ListTile(
            leading: Radio<GemmaBackend>(
              value: GemmaBackend.cpu,
              groupValue: config.backend,
              onChanged: (v) => _updateBackend(context, sheetContext, v!),
            ),
            title: const Text('CPU'),
            subtitle: const Text('Fallback if GPU not available'),
            onTap: () =>
                _updateBackend(context, sheetContext, GemmaBackend.cpu),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _updateBackend(
      BuildContext context, BuildContext sheetContext, GemmaBackend backend) {
    final currentConfig = context.read<ChatSettingsBloc>().state.config;
    context.read<ChatSettingsBloc>().add(
          ChatSettingsUpdateConfig(config: currentConfig.copyWith(backend: backend)),
        );
    Navigator.pop(sheetContext);
  }

  void _showMaxTokensDialog(BuildContext context, ModelConfig config) {
    final controller = TextEditingController(text: '${config.maxTokens}');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Max Tokens'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Maximum tokens (1-8192)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 1 && value <= 8192) {
                context.read<ChatSettingsBloc>().add(
                      ChatSettingsUpdateConfig(
                        config: config.copyWith(maxTokens: value),
                      ),
                    );
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTemperatureDialog(BuildContext context, ModelConfig config) {
    var temperature = config.temperature;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Temperature'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(temperature.toStringAsFixed(2)),
              Slider(
                value: temperature,
                min: 0.0,
                max: 2.0,
                divisions: 40,
                label: temperature.toStringAsFixed(2),
                onChanged: (v) => setDialogState(() => temperature = v),
              ),
              const Text(
                '0 = deterministic, 2 = very creative',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<ChatSettingsBloc>().add(
                      ChatSettingsUpdateConfig(
                        config: config.copyWith(temperature: temperature),
                      ),
                    );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopKDialog(BuildContext context, ModelConfig config) {
    var topK = config.topK;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Top-K'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$topK'),
              Slider(
                value: topK.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                label: '$topK',
                onChanged: (v) => setDialogState(() => topK = v.round()),
              ),
              const Text(
                'Lower = more focused, Higher = more diverse',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<ChatSettingsBloc>().add(
                      ChatSettingsUpdateConfig(
                        config: config.copyWith(topK: topK),
                      ),
                    );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSystemPromptDialog(BuildContext context, String? currentPrompt) {
    final controller = TextEditingController(text: currentPrompt);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('System Prompt'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Default system prompt for new conversations',
            hintText: 'You are a helpful assistant...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final prompt = controller.text.trim();
              context.read<ChatSettingsBloc>().add(
                    ChatSettingsUpdateSystemPrompt(
                      prompt: prompt.isEmpty ? null : prompt,
                    ),
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Settings?'),
        content: const Text(
          'This will reset all chat settings to their default values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ChatSettingsBloc>().add(const ChatSettingsReset());
              Navigator.pop(dialogContext);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
