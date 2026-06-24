import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/constants.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/toolbox/tts_dataset/tts_dataset_project_screen.dart';
import 'package:path/path.dart' as p;
import 'package:tts_dataset/tts_dataset.dart';
import 'package:tts_dataset_bloc/tts_dataset_bloc.dart';

typedef TtsDatasetExportPathProvider =
    Future<String?> Function(TtsDatasetProject project);

class TtsDatasetScreen extends StatefulWidget {
  static const name = 'TTS Dataset';
  static const path = 'tts-dataset';

  const TtsDatasetScreen({this.exportPathProvider, super.key});

  final TtsDatasetExportPathProvider? exportPathProvider;

  @override
  State<TtsDatasetScreen> createState() => _TtsDatasetScreenState();
}

class _TtsDatasetScreenState extends State<TtsDatasetScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TtsDatasetBloc>().add(const TtsDatasetLoadProjects());
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
      body: (_) => Scaffold(
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(
            horizontal: Constants.defaultGridGap,
            vertical: Constants.defaultGridGap,
          ),
          child: BlocBuilder<TtsDatasetBloc, TtsDatasetState>(
            builder: (context, state) {
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
                  if (state.status == TtsDatasetStatus.loading &&
                      state.projects.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.projects.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(context.l10n.ttsDatasetNoProjects),
                      ),
                    )
                  else
                    SliverList.separated(
                      itemBuilder: (context, index) {
                        final project = state.projects[index];
                        return _ProjectListTile(
                          project: project,
                          onExport: () => _exportProject(project),
                          onRemove: () => _confirmRemoveProject(project),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemCount: state.projects.length,
                    ),
                  if (state.errorMessage != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: context.l10n.ttsDatasetCreateProject,
          onPressed: () => _showCreateProjectDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showCreateProjectDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _CreateProjectDialog(
        onCreate: (projectName, language) {
          Navigator.of(dialogContext).pop();
          _createProject(projectName, language);
        },
      ),
    );
  }

  void _createProject(String projectName, String language) {
    context.read<TtsDatasetBloc>().add(
      TtsDatasetCreateProject(
        name: projectName,
        language: language,
        speakerDisplayName: projectName,
        datasetLicense: 'private',
        consentStatus: ConsentStatus.granted,
        rootPath: _createProjectRoot(projectName),
      ),
    );
  }

  Future<void> _exportProject(TtsDatasetProject project) async {
    final outputPath = widget.exportPathProvider == null
        ? await _selectExportPath(project)
        : await widget.exportPathProvider!(project);
    if (!mounted || outputPath == null) return;
    context.read<TtsDatasetBloc>().add(
      TtsDatasetExportProject(projectId: project.id, outputPath: outputPath),
    );
  }

  Future<String?> _selectExportPath(TtsDatasetProject project) {
    return FilePicker.saveFile(
      dialogTitle: context.l10n.ttsDatasetExportZip,
      fileName: '${_slugProjectName(project.name)}.zip',
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
  }

  Future<void> _confirmRemoveProject(TtsDatasetProject project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.ttsDatasetRemoveProject),
        content: Text(
          context.l10n.ttsDatasetRemoveProjectConfirm(project.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.ttsDatasetCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: Text(context.l10n.ttsDatasetRemoveProject),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    context.read<TtsDatasetBloc>().add(
      TtsDatasetDeleteProject(projectId: project.id),
    );
  }

  String _createProjectRoot(String projectName) {
    final slug = _slugProjectName(projectName);
    final directory = Directory(
      p.join(
        Directory.systemTemp.path,
        'gsmlg_tts_datasets',
        '${slug}_${DateTime.now().millisecondsSinceEpoch}',
      ),
    )..createSync(recursive: true);
    return directory.path;
  }

  String _slugProjectName(String projectName) {
    final slug = projectName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? 'dataset' : slug;
  }
}

class _CreateProjectDialog extends StatefulWidget {
  const _CreateProjectDialog({required this.onCreate});

  final void Function(String projectName, String language) onCreate;

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  late final TextEditingController _nameController;
  String? _language;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'My voice');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final englishUs = context.l10n.ttsDatasetEnglishUs;
    final chineseMandarin = context.l10n.ttsDatasetChineseMandarin;
    final language = _language ?? englishUs;
    final projectName = _nameController.text.trim();

    return AlertDialog(
      title: Text(context.l10n.ttsDatasetCreateProject),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: context.l10n.ttsDatasetProjectName,
              ),
              onSubmitted: (_) => _submit(projectName, language),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.ttsDatasetLanguage,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(value: englishUs, label: Text(englishUs)),
                ButtonSegment<String>(
                  value: chineseMandarin,
                  label: Text(chineseMandarin),
                ),
              ],
              selected: {language},
              onSelectionChanged: (selection) {
                setState(() => _language = selection.single);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.ttsDatasetCancel),
        ),
        FilledButton.icon(
          onPressed: projectName.isEmpty
              ? null
              : () => _submit(projectName, language),
          icon: const Icon(Icons.add),
          label: Text(context.l10n.ttsDatasetCreateProject),
        ),
      ],
    );
  }

  void _submit(String projectName, String language) {
    if (projectName.isEmpty) return;
    widget.onCreate(projectName, language);
  }
}

class ToolboxScreenMarker {
  const ToolboxScreenMarker._();

  static const name = 'Toolbox';
}

class _ProjectListTile extends StatelessWidget {
  const _ProjectListTile({
    required this.project,
    required this.onExport,
    required this.onRemove,
  });

  final TtsDatasetProject project;
  final VoidCallback onExport;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.record_voice_over),
      title: Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        project.language,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SizedBox(
        width: 148,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              tooltip: context.l10n.ttsDatasetExportZip,
              onPressed: onExport,
              icon: const Icon(Icons.archive_outlined),
            ),
            IconButton(
              tooltip: context.l10n.ttsDatasetRemoveProject,
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
      onTap: () => context.goNamed(
        TtsDatasetProjectScreen.name,
        pathParameters: {'projectId': project.id},
      ),
    );
  }
}
