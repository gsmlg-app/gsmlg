import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_components/app_components.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github_bloc/github_bloc.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/service/service_screen.dart';
import 'package:url_launcher/url_launcher.dart';

Future<T?> _showLocalThemedDmDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget content,
  List<Widget>? actions,
}) {
  final style = resolvePlatformStyle(context);
  final cupertinoTheme = MaterialBasedCupertinoThemeData(
    materialTheme: Theme.of(context),
  );

  // WORKAROUND(upstream): duskmoon-dev/flutter-duskmoon-ui#17
  return showDialog<T>(
    context: context,
    useRootNavigator: false,
    builder: (context) {
      if (style == DmPlatformStyle.cupertino) {
        return DmPlatformOverride(
          style: style,
          child: CupertinoTheme(
            data: cupertinoTheme,
            child: CupertinoAlertDialog(
              title: title,
              content: content,
              actions: actions ?? const [],
            ),
          ),
        );
      }

      return AlertDialog(title: title, content: content, actions: actions);
    },
  );
}

class GitHubRepoScreen extends StatelessWidget {
  static const name = 'GitHubRepo';
  static const path = ':owner/:repo';

  const GitHubRepoScreen({super.key, required this.owner, required this.repo});

  final String owner;
  final String repo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GitHubBloc, GitHubState>(
      builder: (context, state) {
        if (state is! GitHubConnected) {
          return const Center(child: Text('GitHub not connected'));
        }

        final api = context.read<GitHubBloc>().api;
        if (api == null) {
          return const Center(child: Text('GitHub API not available'));
        }

        return BlocProvider<GitHubActionsBloc>(
          create: (context) =>
              GitHubActionsBloc(api: api, owner: owner, repo: repo)
                ..add(const GitHubActionsFetch()),
          child: _GitHubRepoView(owner: owner, repo: repo),
        );
      },
    );
  }
}

class _GitHubRepoView extends StatelessWidget {
  const _GitHubRepoView({required this.owner, required this.repo});

  final String owner;
  final String repo;

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ServiceScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: Platform.isMacOS
            ? const EdgeInsets.all(kDefaultGridGap)
            : const EdgeInsets.symmetric(horizontal: kDefaultGridGap),
        child: BlocBuilder<GitHubActionsBloc, GitHubActionsState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(repo),
                      Text(owner, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {
                        launchUrl(Uri.parse('https://github.com/$owner/$repo'));
                      },
                    ),
                    if (state is GitHubActionsLoaded)
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          context.read<GitHubActionsBloc>().add(
                            const GitHubActionsRefresh(),
                          );
                        },
                      ),
                  ],
                ),
                if (state is GitHubActionsLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  )
                else if (state is GitHubActionsError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              context.read<GitHubActionsBloc>().add(
                                const GitHubActionsFetch(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state is GitHubActionsLoaded)
                  ..._buildContent(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, GitHubActionsLoaded state) {
    return [
      // Workflows section
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Workflows (${state.workflows.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      if (state.workflows.isEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No workflows found'),
          ),
        )
      else
        SliverList.builder(
          itemCount: state.workflows.length,
          itemBuilder: (context, index) {
            final workflow = state.workflows[index];
            return _WorkflowTile(
              workflow: workflow,
              owner: owner,
              repo: repo,
              isDispatching: state.isDispatching,
            );
          },
        ),

      // Recent runs section
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Recent Runs (${state.runs.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      if (state.runs.isEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('No workflow runs'),
          ),
        )
      else
        SliverList.builder(
          itemCount: state.runs.length,
          itemBuilder: (context, index) {
            final run = state.runs[index];
            return _WorkflowRunTile(run: run);
          },
        ),

      const SliverToBoxAdapter(child: SizedBox(height: 32)),
    ];
  }
}

class _WorkflowTile extends StatelessWidget {
  const _WorkflowTile({
    required this.workflow,
    required this.owner,
    required this.repo,
    required this.isDispatching,
  });

  final GitHubWorkflow workflow;
  final String owner;
  final String repo;
  final bool isDispatching;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        workflow.isActive
            ? Icons.play_circle_outline
            : Icons.pause_circle_outline,
        color: workflow.isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline,
      ),
      title: Text(workflow.name),
      subtitle: Text(workflow.path),
      trailing: workflow.isActive
          ? FilledButton.tonal(
              onPressed: isDispatching
                  ? null
                  : () => _showDispatchDialog(context),
              child: isDispatching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Run'),
            )
          : const Text('Disabled'),
    );
  }

  void _showDispatchDialog(BuildContext context) {
    final branchController = TextEditingController(text: 'main');
    final formKey = GlobalKey<FormState>();
    final textControllers = {
      for (final input in workflow.inputs)
        if (!input.isChoice && !input.isBoolean)
          input.name: TextEditingController(text: input.defaultValue ?? ''),
    };
    final choiceValues = {
      for (final input in workflow.inputs)
        if (input.isChoice &&
            input.defaultValue != null &&
            input.options.contains(input.defaultValue))
          input.name: input.defaultValue!,
    };
    final boolValues = {
      for (final input in workflow.inputs)
        if (input.isBoolean) input.name: input.defaultValue == 'true',
    };

    _showLocalThemedDmDialog(
      context: context,
      title: Text('Run ${workflow.name}'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Material(
            type: MaterialType.transparency,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      type: MaterialType.transparency,
                      child: TextFormField(
                        controller: branchController,
                        decoration: const InputDecoration(
                          labelText: 'Branch/Tag',
                          hintText: 'main',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Branch or tag is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (workflow.hasInputs) ...[
                      const SizedBox(height: 16),
                      ...workflow.inputs.map(
                        (input) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _WorkflowInputField(
                            input: input,
                            textController: textControllers[input.name],
                            choiceValue: choiceValues[input.name],
                            boolValue: boolValues[input.name] ?? false,
                            onChoiceChanged: (value) {
                              setState(() {
                                if (value == null) {
                                  choiceValues.remove(input.name);
                                } else {
                                  choiceValues[input.name] = value;
                                }
                              });
                            },
                            onBoolChanged: (value) {
                              setState(() {
                                boolValues[input.name] = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        DmDialogAction(
          onPressed: (ctx) => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        DmDialogAction(
          onPressed: (ctx) {
            final isValid = formKey.currentState?.validate() ?? false;
            if (!isValid) return;

            final ref = branchController.text.trim();
            if (ref.isNotEmpty) {
              context.read<GitHubActionsBloc>().add(
                GitHubActionsDispatch(
                  workflowId: workflow.id,
                  ref: ref,
                  inputs: _collectInputs(
                    textControllers: textControllers,
                    choiceValues: choiceValues,
                    boolValues: boolValues,
                  ),
                ),
              );
              Navigator.pop(ctx);
            }
          },
          child: const Text('Run'),
        ),
      ],
    );
  }

  Map<String, String>? _collectInputs({
    required Map<String, TextEditingController> textControllers,
    required Map<String, String> choiceValues,
    required Map<String, bool> boolValues,
  }) {
    final inputs = <String, String>{};

    for (final input in workflow.inputs) {
      if (input.isBoolean) {
        inputs[input.name] = (boolValues[input.name] ?? false).toString();
        continue;
      }

      final value = input.isChoice
          ? choiceValues[input.name]
          : textControllers[input.name]?.text;
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        inputs[input.name] = trimmed;
      }
    }

    if (inputs.isEmpty) return null;
    return inputs;
  }
}

class _WorkflowInputField extends StatelessWidget {
  const _WorkflowInputField({
    required this.input,
    required this.choiceValue,
    required this.boolValue,
    required this.onChoiceChanged,
    required this.onBoolChanged,
    this.textController,
  });

  final GitHubWorkflowInput input;
  final TextEditingController? textController;
  final String? choiceValue;
  final bool boolValue;
  final ValueChanged<String?> onChoiceChanged;
  final ValueChanged<bool> onBoolChanged;

  @override
  Widget build(BuildContext context) {
    if (input.isChoice) {
      return DropdownButtonFormField<String>(
        initialValue: choiceValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: _label,
          helperText: input.description,
          border: const OutlineInputBorder(),
        ),
        items: [
          for (final option in input.options)
            DropdownMenuItem(value: option, child: Text(option)),
        ],
        onChanged: onChoiceChanged,
        validator: (value) {
          if (input.required && (value == null || value.trim().isEmpty)) {
            return '${input.name} is required';
          }
          return null;
        },
      );
    }

    if (input.isBoolean) {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(_label),
        subtitle: input.description == null ? null : Text(input.description!),
        value: boolValue,
        onChanged: onBoolChanged,
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: TextFormField(
        controller: textController,
        keyboardType: input.type == 'number' ? TextInputType.number : null,
        decoration: InputDecoration(
          labelText: _label,
          helperText: input.description,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (input.required && (value == null || value.trim().isEmpty)) {
            return '${input.name} is required';
          }
          return null;
        },
      ),
    );
  }

  String get _label => input.required ? '${input.name} *' : input.name;
}

class _WorkflowRunTile extends StatelessWidget {
  const _WorkflowRunTile({required this.run});

  final GitHubWorkflowRun run;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildStatusIcon(context),
      title: Text(run.name ?? 'Workflow Run #${run.runNumber}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${run.event ?? 'unknown'} on ${run.headBranch ?? 'unknown'}'),
          if (run.createdAt != null)
            Text(
              _formatDate(run.createdAt!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (run.isRunning)
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () {
                context.read<GitHubActionsBloc>().add(
                  GitHubActionsCancel(runId: run.id),
                );
              },
            )
          else if (run.isCompleted)
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                context.read<GitHubActionsBloc>().add(
                  GitHubActionsRerun(runId: run.id),
                );
              },
            ),
          if (run.htmlUrl != null)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () {
                launchUrl(Uri.parse(run.htmlUrl!));
              },
            ),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final dmColors = Theme.of(context).extension<DmColorExtension>()!;

    if (run.isRunning) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (run.isSuccess) {
      return Icon(Icons.check_circle, color: dmColors.success);
    }

    if (run.isFailure) {
      return Icon(Icons.cancel, color: Theme.of(context).colorScheme.error);
    }

    if (run.conclusion == 'cancelled') {
      return Icon(
        Icons.block,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    return Icon(
      Icons.help_outline,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.month}/${date.day}/${date.year}';
  }
}
