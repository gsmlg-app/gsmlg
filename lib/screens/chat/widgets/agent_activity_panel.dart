import 'package:chat_bloc/chat_bloc.dart';
import 'package:flutter/material.dart';

/// Compact, collapsible card showing live and recent agent tool invocations
/// and supervised sub-agent tasks in the current conversation.
class AgentActivityPanel extends StatefulWidget {
  const AgentActivityPanel({
    super.key,
    required this.toolActivities,
    required this.subAgents,
    this.isStreaming = false,
  });

  final List<ChatToolActivity> toolActivities;
  final List<ChatSubAgentActivity> subAgents;
  final bool isStreaming;

  @override
  State<AgentActivityPanel> createState() => _AgentActivityPanelState();
}

class _AgentActivityPanelState extends State<AgentActivityPanel> {
  bool _expanded = true;

  @override
  void didUpdateWidget(covariant AgentActivityPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-expand when new live activity arrives during a run.
    if (widget.isStreaming &&
        (widget.toolActivities.length > oldWidget.toolActivities.length ||
            widget.subAgents.length > oldWidget.subAgents.length)) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.toolActivities.isEmpty && widget.subAgents.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final activeTools = widget.toolActivities.where((t) => t.isActive).length;
    final activeSubs = widget.subAgents.where((s) => s.isActive).length;
    final hasActive = activeTools > 0 || activeSubs > 0;

    final summaryParts = <String>[
      if (widget.toolActivities.isNotEmpty)
        '${widget.toolActivities.length} tool${widget.toolActivities.length == 1 ? '' : 's'}',
      if (widget.subAgents.isNotEmpty)
        '${widget.subAgents.length} sub-agent${widget.subAgents.length == 1 ? '' : 's'}',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: hasActive
                ? colorScheme.primary.withValues(alpha: 0.45)
                : colorScheme.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    if (hasActive)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    else
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasActive
                            ? 'Agent active · ${summaryParts.join(' · ')}'
                            : 'Agent activity · ${summaryParts.join(' · ')}',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final sub in widget.subAgents)
                        _SubAgentRow(activity: sub),
                      for (final tool in widget.toolActivities)
                        _ToolRow(activity: tool),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SubAgentRow extends StatelessWidget {
  const _SubAgentRow({required this.activity});

  final ChatSubAgentActivity activity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final indent = ((activity.depth - 1).clamp(0, 3)) * 12.0;

    return Padding(
      padding: EdgeInsets.only(left: indent, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _StatusGlyph(
              isActive: activity.isActive,
              isError: activity.status == 'failed',
              isCancelled: activity.status == 'cancelled',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      size: 13,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        activity.workerName,
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activity.status,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (activity.durationMs != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        _formatDuration(activity.durationMs!),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  activity.error ?? activity.summary ?? activity.goal,
                  style: textTheme.bodySmall?.copyWith(
                    color: activity.status == 'failed'
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({required this.activity});

  final ChatToolActivity activity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _StatusGlyph(
              isActive: activity.isActive,
              isError: activity.isError || activity.status == 'failed',
              isCancelled: activity.status == 'cancelled',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.build_outlined,
                      size: 13,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        activity.toolName,
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (activity.durationMs != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        _formatDuration(activity.durationMs!),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                if (activity.resultPreview != null &&
                    activity.resultPreview!.isNotEmpty)
                  Text(
                    activity.resultPreview!,
                    style: textTheme.bodySmall?.copyWith(
                      color: activity.isError
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusGlyph extends StatelessWidget {
  const _StatusGlyph({
    required this.isActive,
    required this.isError,
    required this.isCancelled,
  });

  final bool isActive;
  final bool isError;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isActive) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 1.8,
          color: colorScheme.primary,
        ),
      );
    }
    if (isError) {
      return Icon(Icons.error_outline, size: 14, color: colorScheme.error);
    }
    if (isCancelled) {
      return Icon(
        Icons.cancel_outlined,
        size: 14,
        color: colorScheme.onSurfaceVariant,
      );
    }
    return Icon(
      Icons.check_circle_outline,
      size: 14,
      color: colorScheme.primary,
    );
  }
}

String _formatDuration(int ms) {
  if (ms < 1000) return '${ms}ms';
  return '${(ms / 1000).toStringAsFixed(1)}s';
}
