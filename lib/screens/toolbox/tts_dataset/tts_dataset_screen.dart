import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/constants.dart';
import 'package:gsmlg/destination.dart';
import 'package:path/path.dart' as p;
import 'package:tts_dataset/tts_dataset.dart';
import 'package:tts_dataset_bloc/tts_dataset_bloc.dart';

class TtsDatasetScreen extends StatefulWidget {
  static const name = 'TTS Dataset';
  static const path = 'tts-dataset';

  const TtsDatasetScreen({super.key});

  @override
  State<TtsDatasetScreen> createState() => _TtsDatasetScreenState();
}

class _TtsDatasetScreenState extends State<TtsDatasetScreen> {
  final _nameController = TextEditingController(text: 'My voice');
  final _speakerController = TextEditingController(text: 'Example Speaker');
  final _languageController = TextEditingController(text: 'English');
  final _licenseController = TextEditingController(text: 'private');

  @override
  void dispose() {
    _nameController.dispose();
    _speakerController.dispose();
    _languageController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(ToolboxScreenMarker.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: const EdgeInsets.symmetric(
          horizontal: Constants.defaultGridGap,
          vertical: Constants.defaultGridGap,
        ),
        child: BlocBuilder<TtsDatasetBloc, TtsDatasetState>(
          builder: (context, state) {
            final selectedProject = state.selectedProject;
            final validation = state.validationResult;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: Text(context.l10n.ttsDatasetTitle),
                  actions: [
                    IconButton(
                      tooltip: context.l10n.ttsDatasetRefresh,
                      onPressed: () => context.read<TtsDatasetBloc>().add(
                        const TtsDatasetLoadProjects(),
                      ),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: _ProjectCreator(
                    nameController: _nameController,
                    speakerController: _speakerController,
                    languageController: _languageController,
                    licenseController: _licenseController,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: _ProjectSummary(
                    state: state,
                    selectedProject: selectedProject,
                    validation: validation,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: _ProjectList(projects: state.projects),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ToolboxScreenMarker {
  const ToolboxScreenMarker._();

  static const name = 'Toolbox';
}

class _ProjectCreator extends StatelessWidget {
  const _ProjectCreator({
    required this.nameController,
    required this.speakerController,
    required this.languageController,
    required this.licenseController,
  });

  final TextEditingController nameController;
  final TextEditingController speakerController;
  final TextEditingController languageController;
  final TextEditingController licenseController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.ttsDatasetProjectName,
                ),
              ),
            ),
            SizedBox(
              width: 260,
              child: TextField(
                controller: speakerController,
                decoration: InputDecoration(
                  labelText: context.l10n.ttsDatasetSpeaker,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                controller: languageController,
                decoration: InputDecoration(
                  labelText: context.l10n.ttsDatasetLanguage,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: TextField(
                controller: licenseController,
                decoration: InputDecoration(
                  labelText: context.l10n.ttsDatasetLicense,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () {
              context.read<TtsDatasetBloc>().add(
                TtsDatasetCreateProject(
                  name: nameController.text,
                  language: languageController.text,
                  speakerDisplayName: speakerController.text,
                  datasetLicense: licenseController.text,
                  consentStatus: ConsentStatus.granted,
                  rootPath: Directory.systemTemp.path,
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: Text(context.l10n.ttsDatasetCreateProject),
          ),
        ),
      ],
    );
  }
}

class _ProjectSummary extends StatelessWidget {
  const _ProjectSummary({
    required this.state,
    required this.selectedProject,
    required this.validation,
  });

  final TtsDatasetState state;
  final TtsDatasetProjectDetail? selectedProject;
  final ValidationResult? validation;

  @override
  Widget build(BuildContext context) {
    final project = selectedProject;
    final acceptedClips =
        project?.clips
            .where((clip) => clip.status == ClipStatus.accepted)
            .length ??
        0;
    final validationLabel = validation == null
        ? context.l10n.ttsDatasetNotValidated
        : validation!.hasErrors
        ? context.l10n.ttsDatasetValidationBlocking(validation!.errors.length)
        : context.l10n.ttsDatasetReady;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project?.project.name ?? context.l10n.ttsDatasetNoProjectSelected,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _Metric(
              label: context.l10n.ttsDatasetProjects,
              value: state.projects.length.toString(),
            ),
            _Metric(
              label: context.l10n.ttsDatasetPrompts,
              value: '${project?.prompts.length ?? 0}',
            ),
            _Metric(
              label: context.l10n.ttsDatasetAcceptedClips,
              value: '$acceptedClips',
            ),
            _Metric(
              label: context.l10n.ttsDatasetValidation,
              value: validationLabel,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: project == null
                  ? null
                  : () => context.read<TtsDatasetBloc>().add(
                      TtsDatasetValidateProject(projectId: project.project.id),
                    ),
              icon: const Icon(Icons.fact_check),
              label: Text(context.l10n.ttsDatasetValidate),
            ),
            OutlinedButton.icon(
              onPressed: project == null
                  ? null
                  : () => context.read<TtsDatasetBloc>().add(
                      TtsDatasetExportProject(
                        projectId: project.project.id,
                        outputPath: p.join(
                          Directory.systemTemp.path,
                          '${project.project.name.replaceAll(' ', '_')}.zip',
                        ),
                      ),
                    ),
              icon: const Icon(Icons.archive),
              label: Text(context.l10n.ttsDatasetExportZip),
            ),
          ],
        ),
        if (state.status == TtsDatasetStatus.loading) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        if (state.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            state.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      avatar: const Icon(Icons.data_object, size: 16),
    );
  }
}

class _ProjectList extends StatelessWidget {
  const _ProjectList({required this.projects});

  final List<TtsDatasetProject> projects;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.ttsDatasetProjects,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: projects
              .map(
                (project) => ActionChip(
                  avatar: const Icon(Icons.record_voice_over, size: 18),
                  label: Text(project.name),
                  onPressed: () => context.read<TtsDatasetBloc>().add(
                    TtsDatasetValidateProject(projectId: project.id),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
