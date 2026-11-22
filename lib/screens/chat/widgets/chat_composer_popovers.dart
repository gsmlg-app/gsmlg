import 'package:app_agent/app_agent.dart';
import 'package:flutter/material.dart';
import 'package:gsmlg/screens/agents/agent_model_config.dart';

/// Action approval policy displayed in the bottom-left composer pill.
enum ChatPermissionMode {
  askForApproval,
  approveForMe,
  fullAccess;

  String get title => switch (this) {
    ChatPermissionMode.askForApproval => 'Ask for approval',
    ChatPermissionMode.approveForMe => 'Approve for me',
    ChatPermissionMode.fullAccess => 'Full access',
  };

  String get description => switch (this) {
    ChatPermissionMode.askForApproval =>
      'Always ask to edit external files and use the internet',
    ChatPermissionMode.approveForMe =>
      'Only ask for actions detected as potentially unsafe',
    ChatPermissionMode.fullAccess =>
      'Unrestricted access to the internet and any tool on your device',
  };

  IconData get icon => switch (this) {
    ChatPermissionMode.askForApproval => Icons.front_hand_outlined,
    ChatPermissionMode.approveForMe => Icons.terminal,
    ChatPermissionMode.fullAccess => Icons.gpp_maybe_outlined,
  };
}

/// Shared surface styling for floating composer popovers anchored directly
/// above the chat composer bar.
class _ComposerPopoverCard extends StatelessWidget {
  const _ComposerPopoverCard({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final effectiveWidth = width.clamp(
      220.0,
      (screenWidth - 24).clamp(220.0, 420.0),
    );

    return Material(
      color: colorScheme.surfaceContainerHigh,
      elevation: 10,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(width: effectiveWidth, child: child),
    );
  }
}

/// Anchors a floating popover directly above [child] and dismisses it on
/// outside taps.
class _AnchoredPopover extends StatefulWidget {
  const _AnchoredPopover({
    required this.popoverWidth,
    required this.alignment,
    required this.triggerBuilder,
    required this.popoverBuilder,
    this.enabled = true,
  });

  final double popoverWidth;
  final Alignment alignment;
  final bool enabled;
  final Widget Function(BuildContext context, bool isOpen, VoidCallback toggle)
  triggerBuilder;
  final Widget Function(BuildContext context, VoidCallback close)
  popoverBuilder;

  @override
  State<_AnchoredPopover> createState() => _AnchoredPopoverState();
}

class _AnchoredPopoverState extends State<_AnchoredPopover> {
  final _link = LayerLink();
  final _portal = OverlayPortalController();
  bool _isOpen = false;

  void _open() {
    if (!widget.enabled || _isOpen) return;
    _portal.show();
    setState(() => _isOpen = true);
  }

  void _close() {
    if (!_isOpen) return;
    _portal.hide();
    if (mounted) setState(() => _isOpen = false);
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  @override
  void didUpdateWidget(covariant _AnchoredPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _isOpen) {
      _portal.hide();
      _isOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRight = widget.alignment == Alignment.topRight;
    final targetAnchor = isRight ? Alignment.topRight : Alignment.topLeft;
    final followerAnchor = isRight
        ? Alignment.bottomRight
        : Alignment.bottomLeft;

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) {
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _close,
                  child: const SizedBox.expand(),
                ),
              ),
              CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                targetAnchor: targetAnchor,
                followerAnchor: followerAnchor,
                offset: const Offset(0, -10),
                child: _ComposerPopoverCard(
                  width: widget.popoverWidth,
                  child: widget.popoverBuilder(context, _close),
                ),
              ),
            ],
          );
        },
        child: widget.triggerBuilder(context, _isOpen, _toggle),
      ),
    );
  }
}

/// `+` composer button that opens an upward floating action sheet for
/// attachments, voice recording, agent settings, and context token info.
class ComposerAddMenuButton extends StatelessWidget {
  const ComposerAddMenuButton({
    super.key,
    required this.enabled,
    required this.onAttachFiles,
    this.onPasteClipboard,
    this.supportsAudio = false,
    this.isRecording = false,
    this.onToggleRecording,
    this.onOpenAgentSettings,
    this.tokenCount = 0,
  });

  final bool enabled;
  final VoidCallback onAttachFiles;
  final VoidCallback? onPasteClipboard;
  final bool supportsAudio;
  final bool isRecording;
  final VoidCallback? onToggleRecording;
  final VoidCallback? onOpenAgentSettings;
  final int tokenCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _AnchoredPopover(
      popoverWidth: 332,
      alignment: Alignment.topLeft,
      enabled: enabled,
      triggerBuilder: (context, isOpen, toggle) {
        return Tooltip(
          message: 'Add',
          child: Material(
            color: isOpen
                ? colorScheme.onSurface.withValues(alpha: 0.1)
                : Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? toggle : null,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 34,
                height: 34,
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 20,
                    color: enabled
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      popoverBuilder: (context, close) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: Text(
                  'Add',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              _PopoverMenuRow(
                icon: Icons.attach_file,
                title: 'Files and folders',
                subtitle: 'Attach files or images',
                onTap: () {
                  close();
                  onAttachFiles();
                },
              ),
              if (onPasteClipboard != null)
                _PopoverMenuRow(
                  icon: Icons.content_paste,
                  title: 'Paste from clipboard',
                  subtitle: 'Attach copied image or file',
                  onTap: () {
                    close();
                    onPasteClipboard!();
                  },
                ),
              if (supportsAudio && onToggleRecording != null)
                _PopoverMenuRow(
                  icon: isRecording ? Icons.stop_circle : Icons.mic_none,
                  iconColor: isRecording ? colorScheme.error : null,
                  title: isRecording ? 'Stop recording' : 'Voice note',
                  subtitle: isRecording
                      ? 'Finish audio capture'
                      : 'Record audio attachment',
                  onTap: () {
                    close();
                    onToggleRecording!();
                  },
                ),
              if (onOpenAgentSettings != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Text(
                    'Agent',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _PopoverMenuRow(
                  icon: Icons.tune,
                  title: 'Agent settings',
                  subtitle: 'Instructions, model & tools',
                  onTap: () {
                    close();
                    onOpenAgentSettings!();
                  },
                ),
              ],
              if (tokenCount > 0) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.toll_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.75,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '~$tokenCount tokens in context',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PopoverMenuRow extends StatelessWidget {
  const _PopoverMenuRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: iconColor ?? colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.78,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Left composer pill showing the active permission mode (`Full access`,
/// `Approve for me`, `Ask for approval`) and opening an upward approval picker
/// popover.
class ComposerPermissionPill extends StatelessWidget {
  const ComposerPermissionPill({
    super.key,
    required this.value,
    required this.onChanged,
    this.onManage,
    this.enabled = true,
  });

  final ChatPermissionMode value;
  final ValueChanged<ChatPermissionMode> onChanged;
  final VoidCallback? onManage;
  final bool enabled;

  Color _accentFor(BuildContext context, ChatPermissionMode mode) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (mode) {
      ChatPermissionMode.fullAccess => const Color(0xFFE06C2D),
      ChatPermissionMode.approveForMe => colorScheme.primary,
      ChatPermissionMode.askForApproval => colorScheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final accent = _accentFor(context, value);

    return _AnchoredPopover(
      popoverWidth: 380,
      alignment: Alignment.topLeft,
      enabled: enabled,
      triggerBuilder: (context, isOpen, toggle) {
        return Tooltip(
          message: 'Permissions: ${value.title}',
          child: _PillTrigger(
            label: value.title,
            isOpen: isOpen,
            accentColor: accent,
            onTap: enabled ? toggle : null,
          ),
        );
      },
      popoverBuilder: (context, close) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 14, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'How should Agent actions be approved?',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (onManage != null)
                      InkWell(
                        onTap: () {
                          close();
                          onManage!();
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            'Manage',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              for (final mode in ChatPermissionMode.values)
                _PermissionOptionRow(
                  mode: mode,
                  isSelected: mode == value,
                  accentColor: _accentFor(context, mode),
                  onTap: () {
                    close();
                    if (mode != value) onChanged(mode);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PermissionOptionRow extends StatelessWidget {
  const _PermissionOptionRow({
    required this.mode,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  final ChatPermissionMode mode;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDanger = mode == ChatPermissionMode.fullAccess;
    final titleColor = isDanger
        ? accentColor
        : (isSelected ? accentColor : colorScheme.onSurface);
    final subtitleColor = isDanger
        ? accentColor.withValues(alpha: 0.82)
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Icon(
                mode.icon,
                size: 19,
                color: isDanger
                    ? accentColor
                    : (isSelected ? accentColor : colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mode.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mode.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check, size: 18, color: titleColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Left composer pill showing the active agent (or mode) and opening an
/// upward selector popover styled like a clean action approval / agent picker.
class ComposerAgentPill extends StatelessWidget {
  const ComposerAgentPill({
    super.key,
    required this.selectedAgentName,
    this.selectedAgentId,
    this.agents = const [],
    this.onAgentSelect,
    this.onManageAgents,
  });

  final String selectedAgentName;
  final String? selectedAgentId;
  final List<AgentDefinition> agents;
  final ValueChanged<String>? onAgentSelect;
  final VoidCallback? onManageAgents;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canOpenPopover = agents.isNotEmpty && onAgentSelect != null;

    if (!canOpenPopover) {
      return _PillTrigger(
        label: selectedAgentName,
        isOpen: false,
        accentColor: colorScheme.primary,
        onTap: onManageAgents,
      );
    }

    return _AnchoredPopover(
      popoverWidth: 340,
      alignment: Alignment.topLeft,
      triggerBuilder: (context, isOpen, toggle) {
        return _PillTrigger(
          label: selectedAgentName,
          isOpen: isOpen,
          accentColor: colorScheme.primary,
          onTap: toggle,
        );
      },
      popoverBuilder: (context, close) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select agent',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (onManageAgents != null)
                      InkWell(
                        onTap: () {
                          close();
                          onManageAgents!();
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            'Manage',
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final agent in agents)
                        _AgentOptionRow(
                          agent: agent,
                          isSelected: agent.id == selectedAgentId,
                          onTap: () {
                            close();
                            if (agent.id != selectedAgentId) {
                              onAgentSelect?.call(agent.id);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PillTrigger extends StatelessWidget {
  const _PillTrigger({
    required this.label,
    required this.isOpen,
    required this.accentColor,
    this.onTap,
  });

  final String label;
  final bool isOpen;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isOpen
          ? colorScheme.onSurface.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: accentColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AgentOptionRow extends StatelessWidget {
  const _AgentOptionRow({
    required this.agent,
    required this.isSelected,
    required this.onTap,
  });

  final AgentDefinition agent;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final modelHint = agent.config.inferenceMode == ChatInferenceMode.remote
        ? (agent.config.remoteModel.isNotEmpty
              ? agent.config.remoteModel
              : 'Remote model')
        : (agent.config.localModelId ?? 'Local model');
    final subtitle = (agent.description?.trim().isNotEmpty ?? false)
        ? agent.description!.trim()
        : modelHint;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Center(
                  child: agent.avatar != null && agent.avatar!.isNotEmpty
                      ? Text(
                          agent.avatar!,
                          style: const TextStyle(fontSize: 16),
                        )
                      : Icon(
                          Icons.smart_toy_outlined,
                          size: 18,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      agent.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.78)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check, size: 18, color: colorScheme.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Right composer trigger showing `<ModelName> <Effort>` and opening an
/// upward floating popover with a stepped pill slider for thinking effort
/// plus an inline model switcher.
class ComposerModelEffortControl extends StatelessWidget {
  const ComposerModelEffortControl({
    super.key,
    this.modelName,
    this.thinkingEffort,
    this.thinkingEnabled = false,
    this.enabled = true,
    this.onThinkingEffortChanged,
    this.onThinkingToggle,
    this.onModelTap,
    this.modelChoices = const [],
    this.onModelChoiceSelect,
    this.installedModels = const [],
    this.remoteModels = const [],
    this.selectedModelId,
    this.onModelSelect,
  });

  final String? modelName;
  final RemoteThinkingEffort? thinkingEffort;
  final bool thinkingEnabled;
  final bool enabled;
  final ValueChanged<RemoteThinkingEffort>? onThinkingEffortChanged;
  final ValueChanged<bool>? onThinkingToggle;
  final VoidCallback? onModelTap;
  final List<AgentModelChoice> modelChoices;
  final ValueChanged<AgentModelChoice>? onModelChoiceSelect;
  final List<String> installedModels;
  final List<String> remoteModels;
  final String? selectedModelId;
  final ValueChanged<String>? onModelSelect;

  bool get _hasEffortSlider =>
      thinkingEffort != null && onThinkingEffortChanged != null;

  bool get _hasBooleanThinking => !_hasEffortSlider && onThinkingToggle != null;

  bool get _hasAdjustableThinking => _hasEffortSlider || _hasBooleanThinking;

  bool get _hasModelChoices =>
      (modelChoices.isNotEmpty && onModelChoiceSelect != null) ||
      ((installedModels.isNotEmpty || remoteModels.isNotEmpty) &&
          onModelSelect != null);

  String? get _effortLabel {
    if (thinkingEffort != null) {
      return thinkingEffort!.displayName;
    }
    if (onThinkingToggle != null) {
      return thinkingEnabled ? 'On' : 'Off';
    }
    if (thinkingEnabled) {
      return 'Think';
    }
    return null;
  }

  String get _tooltip {
    if (thinkingEffort != null) {
      return 'Thinking: ${thinkingEffort!.displayName}';
    }
    if (onThinkingToggle != null) {
      return thinkingEnabled ? 'Thinking: On' : 'Thinking: Off';
    }
    return modelName ?? 'Model';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayModel = modelName?.trim().isNotEmpty == true
        ? modelName!.trim()
        : null;
    final effortLabel = _effortLabel;

    if (displayModel == null && !_hasAdjustableThinking && !_hasModelChoices) {
      return const SizedBox.shrink();
    }

    return _AnchoredPopover(
      popoverWidth: 300,
      alignment: Alignment.topRight,
      enabled: enabled,
      triggerBuilder: (context, isOpen, toggle) {
        return Tooltip(
          message: _tooltip,
          child: Material(
            color: isOpen
                ? colorScheme.onSurface.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? toggle : null,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: isOpen
                    ? Text(
                        _hasAdjustableThinking
                            ? 'Select effort'
                            : 'Select model',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : _ModelEffortInlineLabel(
                        modelName: displayModel,
                        effortLabel: effortLabel,
                      ),
              ),
            ),
          ),
        );
      },
      popoverBuilder: (context, close) {
        return _ModelEffortPopoverBody(
          displayModel: displayModel,
          hasEffortSlider: _hasEffortSlider,
          hasBooleanThinking: _hasBooleanThinking,
          thinkingEffort: thinkingEffort,
          thinkingEnabled: thinkingEnabled,
          onThinkingEffortChanged: onThinkingEffortChanged,
          onThinkingToggle: onThinkingToggle,
          modelChoices: modelChoices,
          onModelChoiceSelect: onModelChoiceSelect,
          installedModels: installedModels,
          remoteModels: remoteModels,
          selectedModelId: selectedModelId,
          onModelSelect: onModelSelect,
          onModelTap: onModelTap,
          onClose: close,
        );
      },
    );
  }
}

class _ModelEffortPopoverBody extends StatefulWidget {
  const _ModelEffortPopoverBody({
    required this.displayModel,
    required this.hasEffortSlider,
    required this.hasBooleanThinking,
    required this.thinkingEffort,
    required this.thinkingEnabled,
    required this.onThinkingEffortChanged,
    required this.onThinkingToggle,
    required this.modelChoices,
    required this.onModelChoiceSelect,
    required this.installedModels,
    required this.remoteModels,
    required this.selectedModelId,
    required this.onModelSelect,
    required this.onModelTap,
    required this.onClose,
  });

  final String? displayModel;
  final bool hasEffortSlider;
  final bool hasBooleanThinking;
  final RemoteThinkingEffort? thinkingEffort;
  final bool thinkingEnabled;
  final ValueChanged<RemoteThinkingEffort>? onThinkingEffortChanged;
  final ValueChanged<bool>? onThinkingToggle;
  final List<AgentModelChoice> modelChoices;
  final ValueChanged<AgentModelChoice>? onModelChoiceSelect;
  final List<String> installedModels;
  final List<String> remoteModels;
  final String? selectedModelId;
  final ValueChanged<String>? onModelSelect;
  final VoidCallback? onModelTap;
  final VoidCallback onClose;

  @override
  State<_ModelEffortPopoverBody> createState() =>
      _ModelEffortPopoverBodyState();
}

class _ModelEffortPopoverBodyState extends State<_ModelEffortPopoverBody> {
  late bool _pickingModel;
  late RemoteThinkingEffort? _effort;
  late bool _thinkingEnabled;
  late String? _activeModelName;

  bool get _hasAdjustableThinking =>
      widget.hasEffortSlider || widget.hasBooleanThinking;

  bool get _canPickModels =>
      (widget.modelChoices.isNotEmpty && widget.onModelChoiceSelect != null) ||
      ((widget.installedModels.isNotEmpty || widget.remoteModels.isNotEmpty) &&
          widget.onModelSelect != null);

  @override
  void initState() {
    super.initState();
    _effort = widget.thinkingEffort;
    _thinkingEnabled = widget.thinkingEnabled;
    _activeModelName = widget.displayModel;
    _pickingModel = !_hasAdjustableThinking && _canPickModels;
  }

  @override
  void didUpdateWidget(covariant _ModelEffortPopoverBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.thinkingEffort != oldWidget.thinkingEffort) {
      _effort = widget.thinkingEffort;
    }
    if (widget.thinkingEnabled != oldWidget.thinkingEnabled) {
      _thinkingEnabled = widget.thinkingEnabled;
    }
    if (widget.displayModel != oldWidget.displayModel) {
      _activeModelName = widget.displayModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pickingModel) {
      return _buildModelListView(context);
    }
    return _buildEffortView(context);
  }

  Widget _buildEffortView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stops = widget.hasEffortSlider
        ? RemoteThinkingEffort.values
              .map((e) => e.displayName)
              .toList(growable: false)
        : const ['Off', 'On'];
    final currentIndex = widget.hasEffortSlider
        ? RemoteThinkingEffort.values.indexOf(
            _effort ?? RemoteThinkingEffort.off,
          )
        : (_thinkingEnabled ? 1 : 0);
    final currentLabel = stops[currentIndex];
    final isActive = currentIndex > 0;

    void selectIndex(int index) {
      setState(() {
        if (widget.hasEffortSlider) {
          final next = RemoteThinkingEffort.values[index];
          _effort = next;
          _thinkingEnabled = next != RemoteThinkingEffort.off;
          widget.onThinkingEffortChanged?.call(next);
        } else {
          _thinkingEnabled = index > 0;
          widget.onThinkingToggle?.call(index > 0);
        }
      });
    }

    void reset() {
      if (widget.hasEffortSlider) {
        selectIndex(
          RemoteThinkingEffort.values.indexOf(RemoteThinkingEffort.high),
        );
      } else {
        selectIndex(0);
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_hasAdjustableThinking)
            SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    currentLabel,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: InkWell(
                      onTap: reset,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.refresh,
                          size: 17,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_activeModelName != null || _canPickModels) ...[
            if (_hasAdjustableThinking) const SizedBox(height: 2),
            Center(
              child: InkWell(
                onTap: _canPickModels
                    ? () => setState(() => _pickingModel = true)
                    : (widget.onModelTap == null
                          ? null
                          : () {
                              widget.onClose();
                              widget.onModelTap!();
                            }),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _activeModelName ?? 'Select model',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (_canPickModels || widget.onModelTap != null) ...[
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (_hasAdjustableThinking) ...[
            const SizedBox(height: 14),
            _EffortPillSlider(
              stops: stops,
              selectedIndex: currentIndex,
              onChanged: selectIndex,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < stops.length; i++)
                  InkWell(
                    onTap: () => selectIndex(i),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        stops[i],
                        style: textTheme.labelSmall?.copyWith(
                          color: i == currentIndex
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.72,
                                ),
                          fontWeight: i == currentIndex
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModelListView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 12, 6),
            child: Row(
              children: [
                if (_hasAdjustableThinking)
                  InkWell(
                    onTap: () => setState(() => _pickingModel = false),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.chevron_left,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Select model',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.onModelTap != null)
                  InkWell(
                    onTap: () {
                      widget.onClose();
                      widget.onModelTap!();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Text(
                        'Manage',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.modelChoices.isNotEmpty &&
                      widget.onModelChoiceSelect != null)
                    for (final choice in widget.modelChoices)
                      _ModelChoiceRow(
                        icon: choice.icon,
                        title: choice.title,
                        subtitle: choice.subtitle,
                        isSelected:
                            choice.title == _activeModelName ||
                            (choice.localModelId != null &&
                                choice.localModelId == widget.selectedModelId),
                        onTap: () {
                          setState(() {
                            _activeModelName = choice.title;
                            if (_hasAdjustableThinking) {
                              _pickingModel = false;
                            }
                          });
                          widget.onModelChoiceSelect!(choice);
                          if (!_hasAdjustableThinking) widget.onClose();
                        },
                      )
                  else
                    for (final id in [
                      ...widget.installedModels,
                      ...widget.remoteModels,
                    ])
                      _ModelChoiceRow(
                        icon: Icons.smart_toy_outlined,
                        title: GemmaModelInfo.findById(id)?.displayName ?? id,
                        isSelected:
                            id == widget.selectedModelId ||
                            id == _activeModelName,
                        onTap: () {
                          setState(() {
                            _activeModelName =
                                GemmaModelInfo.findById(id)?.displayName ?? id;
                            if (_hasAdjustableThinking) {
                              _pickingModel = false;
                            }
                          });
                          widget.onModelSelect?.call(id);
                          if (!_hasAdjustableThinking) widget.onClose();
                        },
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelChoiceRow extends StatelessWidget {
  const _ModelChoiceRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check, size: 17, color: colorScheme.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ModelEffortInlineLabel extends StatelessWidget {
  const _ModelEffortInlineLabel({
    required this.modelName,
    required this.effortLabel,
  });

  final String? modelName;
  final String? effortLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (modelName != null)
          Flexible(
            child: Text(
              modelName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        if (effortLabel != null) ...[
          if (modelName != null) const SizedBox(width: 5),
          Text(
            effortLabel!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom pill-shaped stepped effort slider with discrete stop dots,
/// active primary fill, and circular thumb matching the reference popover.
class _EffortPillSlider extends StatelessWidget {
  const _EffortPillSlider({
    required this.stops,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> stops;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _height = 38.0;
  static const _thumbDiameter = 32.0;
  static const _inset = (_height - _thumbDiameter) / 2;

  int _indexForDx(double dx, double width) {
    final maxIndex = stops.length - 1;
    if (maxIndex <= 0) return 0;
    final usable = (width - _thumbDiameter - _inset * 2).clamp(1.0, width);
    final normalized = ((dx - _inset - _thumbDiameter / 2) / usable).clamp(
      0.0,
      1.0,
    );
    return (normalized * maxIndex).round().clamp(0, maxIndex);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxIndex = stops.length - 1;
    final fraction = maxIndex > 0 ? selectedIndex / maxIndex : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final travel = (width - _thumbDiameter - _inset * 2).clamp(0.0, width);
        final thumbLeft = _inset + travel * fraction;
        final fillWidth = thumbLeft + _thumbDiameter + _inset;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) =>
              onChanged(_indexForDx(details.localPosition.dx, width)),
          onHorizontalDragUpdate: (details) =>
              onChanged(_indexForDx(details.localPosition.dx, width)),
          child: SizedBox(
            height: _height,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Pill background track
                Container(
                  height: _height,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(_height / 2),
                  ),
                ),
                // Active filled capsule
                if (selectedIndex > 0)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    width: fillWidth.clamp(_height, width),
                    height: _height,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(_height / 2),
                    ),
                  ),
                // Step dots
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _inset + _thumbDiameter / 2 - 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < stops.length; i++)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < selectedIndex
                                  ? colorScheme.onPrimary.withValues(
                                      alpha: 0.55,
                                    )
                                  : colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.4,
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Circular thumb
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOutCubic,
                  left: thumbLeft,
                  top: _inset,
                  child: Container(
                    width: _thumbDiameter,
                    height: _thumbDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.onPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.22),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
