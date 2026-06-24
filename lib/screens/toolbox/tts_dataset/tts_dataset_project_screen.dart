import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/constants.dart';
import 'package:gsmlg/destination.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:tts_dataset/tts_dataset.dart';
import 'package:tts_dataset_bloc/tts_dataset_bloc.dart';

typedef TtsDatasetAudioRecorderFactory = TtsDatasetAudioRecorder Function();
typedef TtsDatasetPlayRecording = Future<bool> Function(String path);

abstract class TtsDatasetAudioRecorder {
  Future<bool> hasPermission();

  Future<void> start({required String path});

  Future<String?> stop();

  Future<bool> isRecording();

  Future<void> dispose();
}

Future<Source> ttsDatasetRecordingSource(File file) async {
  return BytesSource(await file.readAsBytes(), mimeType: 'audio/wav');
}

class TtsDatasetProjectScreen extends StatefulWidget {
  static const name = 'TTS Dataset Project';
  static const path = ':projectId';

  const TtsDatasetProjectScreen({
    required this.projectId,
    this.recorderFactory,
    this.playRecording,
    super.key,
  });

  final String projectId;
  final TtsDatasetAudioRecorderFactory? recorderFactory;
  final TtsDatasetPlayRecording? playRecording;

  @override
  State<TtsDatasetProjectScreen> createState() =>
      _TtsDatasetProjectScreenState();
}

class _TtsDatasetProjectScreenState extends State<TtsDatasetProjectScreen> {
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    context.read<TtsDatasetBloc>().add(
      TtsDatasetOpenProject(projectId: widget.projectId),
    );
  }

  @override
  void didUpdateWidget(TtsDatasetProjectScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
      context.read<TtsDatasetBloc>().add(
        TtsDatasetOpenProject(projectId: widget.projectId),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(const Key('Toolbox'), context),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        minimum: const EdgeInsets.symmetric(
          horizontal: Constants.defaultGridGap,
          vertical: Constants.defaultGridGap,
        ),
        child: BlocBuilder<TtsDatasetBloc, TtsDatasetState>(
          builder: (context, state) {
            final detail = state.selectedProject;
            final isCurrentProject = detail?.project.id == widget.projectId;
            if (!isCurrentProject && state.status == TtsDatasetStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final currentDetail = isCurrentProject ? detail! : null;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  leading: IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  title: Text(
                    currentDetail?.project.name ?? context.l10n.ttsDatasetTitle,
                  ),
                  actions: [
                    IconButton(
                      tooltip: context.l10n.ttsDatasetRefresh,
                      onPressed: () => context.read<TtsDatasetBloc>().add(
                        TtsDatasetOpenProject(projectId: widget.projectId),
                      ),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                if (currentDetail == null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        state.errorMessage ??
                            context.l10n.ttsDatasetProjectNotFound,
                      ),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        context.l10n.ttsDatasetTrainingText,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SliverList.separated(
                    itemBuilder: (context, index) {
                      final prompt = currentDetail.prompts[index];
                      final clip = _recordingForPrompt(currentDetail, prompt);
                      return _PromptRecordTile(
                        prompt: prompt,
                        clip: clip,
                        onRecord: () =>
                            _showRecordDialog(currentDetail, prompt),
                        onClear: clip == null
                            ? null
                            : () => context.read<TtsDatasetBloc>().add(
                                TtsDatasetClearPromptRecording(
                                  projectId: currentDetail.project.id,
                                  promptId: prompt.id,
                                ),
                              ),
                        onPlay: clip == null
                            ? null
                            : () => _playClip(currentDetail, clip),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemCount: currentDetail.prompts.length,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showRecordDialog(
    TtsDatasetProjectDetail detail,
    TrainingTextItem prompt,
  ) async {
    final recorder = widget.recorderFactory?.call() ?? _RecordAudioRecorder();
    var isRecording = false;
    DateTime? startedAt;

    Future<void> startRecording(StateSetter setDialogState) async {
      if (!await recorder.hasPermission()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.ttsDatasetMicrophoneDenied)),
        );
        return;
      }

      final tempDirectory = await Directory.systemTemp.createTemp(
        'tts_dataset_recording_',
      );
      final recordingPath = p.join(
        tempDirectory.path,
        '${prompt.id}-${DateTime.now().microsecondsSinceEpoch}.wav',
      );
      await recorder.start(path: recordingPath);
      if (!mounted) return;
      setDialogState(() {
        isRecording = true;
        startedAt = DateTime.now();
      });
    }

    Future<void> stopRecording(
      BuildContext dialogContext,
      StateSetter setDialogState,
    ) async {
      final recordingPath = await recorder.stop();
      final recordingStartedAt = startedAt;
      if (!mounted) return;
      setDialogState(() => isRecording = false);
      if (recordingPath == null) return;

      final durationMs = recordingStartedAt == null
          ? 0
          : DateTime.now().difference(recordingStartedAt).inMilliseconds;
      context.read<TtsDatasetBloc>().add(
        TtsDatasetSavePromptRecording(
          projectId: detail.project.id,
          promptId: prompt.id,
          recordingPath: recordingPath,
          durationMs: durationMs,
        ),
      );
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(context.l10n.ttsDatasetRecordAudio),
              content: SizedBox(
                width: 520,
                child: Text(
                  prompt.rawText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isRecording
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: Text(context.l10n.ttsDatasetCancel),
                ),
                FilledButton.icon(
                  onPressed: isRecording
                      ? () => stopRecording(dialogContext, setDialogState)
                      : () => startRecording(setDialogState),
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  label: Text(
                    isRecording
                        ? context.l10n.ttsDatasetStopRecording
                        : context.l10n.ttsDatasetRecordAudio,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (await recorder.isRecording()) {
      await recorder.stop();
    }
    await recorder.dispose();
  }

  Future<void> _playClip(TtsDatasetProjectDetail detail, AudioClip clip) async {
    final file = File(p.join(detail.project.rootPath, clip.exportWavPath));
    if (!file.existsSync()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ttsDatasetNoRecordingToPlay)),
      );
      return;
    }

    try {
      final played = widget.playRecording == null
          ? await _playRecording(file.path)
          : await widget.playRecording!(file.path);
      if (!played && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.ttsDatasetPlaybackUnavailable)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ttsDatasetPlaybackUnavailable)),
      );
    }
  }

  Future<bool> _playRecording(String path) async {
    final player = _audioPlayer ??= AudioPlayer();
    await player.stop();
    await player.play(await ttsDatasetRecordingSource(File(path)));
    return true;
  }

  AudioClip? _recordingForPrompt(
    TtsDatasetProjectDetail detail,
    TrainingTextItem prompt,
  ) {
    AudioClip? latestClip;
    for (final clip in detail.clips) {
      if (clip.promptId == prompt.id && clip.status == ClipStatus.accepted) {
        latestClip = clip;
      }
    }
    return latestClip;
  }
}

class _RecordAudioRecorder implements TtsDatasetAudioRecorder {
  final AudioRecorder _recorder = AudioRecorder();

  @override
  Future<void> dispose() => _recorder.dispose();

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<bool> isRecording() => _recorder.isRecording();

  @override
  Future<void> start({required String path}) {
    return _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 24000,
        numChannels: 1,
      ),
      path: path,
    );
  }

  @override
  Future<String?> stop() => _recorder.stop();
}

class _PromptRecordTile extends StatelessWidget {
  const _PromptRecordTile({
    required this.prompt,
    required this.clip,
    required this.onRecord,
    required this.onClear,
    required this.onPlay,
  });

  final TrainingTextItem prompt;
  final AudioClip? clip;
  final VoidCallback onRecord;
  final VoidCallback? onClear;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final isRecorded = clip != null || prompt.status == PromptStatus.recorded;
    return ListTile(
      leading: Icon(
        isRecorded ? Icons.check_circle : Icons.mic_none,
        color: isRecorded ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(prompt.rawText, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        isRecorded
            ? context.l10n.ttsDatasetRecorded
            : context.l10n.ttsDatasetNeedsAudio,
      ),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            tooltip: context.l10n.ttsDatasetRecordAudio,
            onPressed: onRecord,
            icon: const Icon(Icons.mic),
          ),
          IconButton(
            tooltip: context.l10n.ttsDatasetClearRecording,
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline),
          ),
          IconButton(
            tooltip: context.l10n.ttsDatasetPlayRecording,
            onPressed: onPlay,
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}
