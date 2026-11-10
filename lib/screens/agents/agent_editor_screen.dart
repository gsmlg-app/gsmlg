import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_agent/app_agent.dart';
import 'package:app_locale/app_locale.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/home/home_screen.dart';

import 'agent_model_config.dart';
import 'agent_sessions_screen.dart';

/// Creates ([agentId] null) or edits an agent: profile, instructions, model,
/// thinking and the tools it may call. Changes are saved on "Save".
class AgentEditorScreen extends StatefulWidget {
  static const name = 'AgentEdit';
  static const path = 'edit';
  static const createName = 'AgentCreate';
  static const createPath = 'agents/new';

  const AgentEditorScreen({this.agentId, super.key});

  /// How long Save waits for the settings bloc before reporting a failure.
  static const saveTimeout = Duration(seconds: 10);

  final String? agentId;

  @override
  State<AgentEditorScreen> createState() => _AgentEditorScreenState();
}

class _AgentEditorScreenState extends State<AgentEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _avatar = TextEditingController();
  final _description = TextEditingController();
  final _instructions = TextEditingController();
  late ModelConfig _config;
  bool _thinkingEnabled = false;

  /// Null allows every tool.
  Set<String>? _allowedTools;
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    try {
      context.read<GemmaModelBloc>().add(const GemmaModelListInstalled());
    } catch (_) {
      // Route previews may mount the editor without local model providers.
    }
    final settings = context.read<ChatSettingsBloc>().state;
    if (widget.agentId == null) {
      final choices = configuredAgentModels(context);
      _config = choices.isNotEmpty ? choices.first.config : settings.config;
      _initialized = true;
    } else {
      _config = settings.config;
      _initFrom(_agentIn(settings));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _avatar.dispose();
    _description.dispose();
    _instructions.dispose();
    super.dispose();
  }

  AgentDefinition? _agentIn(ChatSettingsState state) =>
      state.agents.where((agent) => agent.id == widget.agentId).firstOrNull;

  void _initFrom(AgentDefinition? agent) {
    if (agent == null || _initialized) return;
    _initialized = true;
    _name.text = agent.name;
    _avatar.text = agent.avatar ?? '';
    _description.text = agent.description ?? '';
    _instructions.text = agent.instructions ?? '';
    _config = agent.config;
    _thinkingEnabled = agent.thinkingEnabled;
    _allowedTools = agent.allowedTools?.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(const Key(HomeScreen.name), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => Scaffold(
        appBar: DmAppBar(
          restoreNavigation: true,
          title: Text(
            widget.agentId == null
                ? l10n.agentEditorCreateTitle
                : l10n.agentEditorEditTitle,
          ),
        ),
        body: BlocConsumer<ChatSettingsBloc, ChatSettingsState>(
          listenWhen: (_, _) => !_initialized,
          listener: (context, state) =>
              setState(() => _initFrom(_agentIn(state))),
          buildWhen: (previous, current) =>
              _agentIn(previous) == null || _agentIn(current) == null,
          builder: (context, state) {
            if (!_initialized) {
              return Center(
                child: state.isLoaded
                    ? Text(l10n.agentsNotFound)
                    : const CircularProgressIndicator(),
              );
            }
            return _buildForm(context);
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tools = _toolDefinitions(context);
    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
    Widget field(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: child,
    );

    return Form(
      key: _formKey,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              header(l10n.agentEditorProfile),
              field(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 96,
                      child: TextFormField(
                        controller: _avatar,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24),
                        inputFormatters: [_GraphemeLimitFormatter(2)],
                        decoration: InputDecoration(
                          labelText: l10n.agentEditorAvatar,
                          hintText: '🤖',
                          helperText: l10n.agentEditorAvatarHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.agentEditorName,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? l10n.agentEditorNameRequired
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              field(
                TextFormField(
                  controller: _description,
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    labelText: l10n.agentEditorDescription,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              field(
                TextFormField(
                  controller: _instructions,
                  minLines: 4,
                  maxLines: 12,
                  decoration: InputDecoration(
                    labelText: l10n.agentEditorInstructions,
                    hintText: l10n.agentEditorInstructionsHint,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              header(l10n.agentEditorModelSettings),
              AgentModelConfigTiles(
                config: _config,
                onChanged: (config) => setState(() => _config = config),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.psychology),
                title: Text(l10n.agentEditorThinking),
                subtitle: Text(l10n.agentEditorThinkingDescription),
                value: _thinkingEnabled,
                onChanged: (value) => setState(() => _thinkingEnabled = value),
              ),
              header(l10n.agentEditorTools),
              SwitchListTile(
                secondary: const Icon(Icons.handyman_outlined),
                title: Text(l10n.agentEditorAllTools),
                subtitle: Text(l10n.agentEditorAllToolsDescription),
                value: _allowedTools == null,
                onChanged: (all) => setState(
                  () => _allowedTools = all
                      ? null
                      : {for (final tool in tools) tool.name},
                ),
              ),
              if (_allowedTools != null)
                for (final tool in tools)
                  CheckboxListTile(
                    title: Text(tool.name),
                    subtitle: Text(
                      tool.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    value: _allowedTools!.contains(tool.name),
                    onChanged: (checked) => setState(() {
                      if (checked ?? false) {
                        _allowedTools!.add(tool.name);
                      } else {
                        _allowedTools!.remove(tool.name);
                      }
                    }),
                  ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text(l10n.save),
                    onPressed: _saving ? null : _save,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ChatToolDefinition> _toolDefinitions(BuildContext context) {
    try {
      return context.read<ToolExecutor>().toolDefinitions;
    } catch (_) {
      return const [];
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bloc = context.read<ChatSettingsBloc>();
    final id =
        widget.agentId ?? 'agent-${DateTime.now().microsecondsSinceEpoch}';
    final before = _agentIn(bloc.state);
    final allowedTools = _allowedTools;
    setState(() => _saving = true);
    // Completes on the state produced by this save: a new definition object
    // for [id], or the error it raised.
    final saved = bloc.stream
        .firstWhere(
          (state) =>
              state.status == ChatSettingsStatus.error ||
              state.agents.any(
                (agent) => agent.id == id && !identical(agent, before),
              ),
        )
        .timeout(AgentEditorScreen.saveTimeout);
    bloc.add(
      ChatSettingsSaveAgent(
        id: id,
        name: _name.text,
        avatar: _avatar.text,
        description: _description.text,
        instructions: _instructions.text,
        config: _config,
        thinkingEnabled: _thinkingEnabled,
        allowedTools: allowedTools?.toList(),
        clearAllowedTools: allowedTools == null,
      ),
    );
    String? error;
    try {
      final state = await saved;
      if (state.status == ChatSettingsStatus.error) {
        error = state.errorMessage;
      }
    } catch (_) {
      error = '';
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.isEmpty ? context.l10n.agentEditorSaveFailed : error,
          ),
        ),
      );
      return;
    }
    context.goNamed(AgentSessionsScreen.name, pathParameters: {'agentId': id});
  }
}

/// Keeps at most [max] user-perceived characters (e.g. one or two emoji).
class _GraphemeLimitFormatter extends TextInputFormatter {
  _GraphemeLimitFormatter(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final characters = newValue.text.characters;
    if (characters.length <= max) return newValue;
    final text = characters.take(max).toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
