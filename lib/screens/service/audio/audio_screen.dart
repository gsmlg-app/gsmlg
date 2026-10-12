import 'dart:async';
import 'dart:io';

import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_audio/audio.dart';
import 'package:app_locale/app_locale.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gsmlg/constants.dart';
import 'package:gsmlg/destination.dart';
import 'package:gsmlg/screens/service/service_screen.dart';
import 'package:gsmlg/screens/settings/audio_settings_screen.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';

typedef AudioScreenAudioRecorderFactory = AudioScreenAudioRecorder Function();
typedef AudioScreenAudioPlayerFactory = AudioScreenAudioPlayer Function();

abstract class AudioScreenAudioRecorder {
  Future<bool> hasPermission();
  Future<void> start({required String path});
  Future<String?> stop();
  Future<bool> isRecording();
  Future<void> dispose();
}

class DefaultAudioScreenAudioRecorder implements AudioScreenAudioRecorder {
  DefaultAudioScreenAudioRecorder([AudioRecorder? recorder])
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

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

  @override
  Future<void> dispose() => _recorder.dispose();
}

abstract class AudioScreenAudioPlayer {
  Stream<PlayerState> get onPlayerStateChanged;
  Stream<Duration> get onDurationChanged;
  Stream<Duration> get onPositionChanged;
  Stream<void> get onPlayerComplete;
  Future<Duration?> getDuration();
  Future<void> setSource(Source source);
  Future<void> play(Source source);
  Future<void> resume();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> dispose();
}

class DefaultAudioScreenAudioPlayer implements AudioScreenAudioPlayer {
  DefaultAudioScreenAudioPlayer([AudioPlayer? player])
    : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  @override
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  @override
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  @override
  Stream<void> get onPlayerComplete => _player.onPlayerComplete;

  @override
  Future<Duration?> getDuration() => _player.getDuration();

  @override
  Future<void> setSource(Source source) => _player.setSource(source);

  @override
  Future<void> play(Source source) => _player.play(source);

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() => _player.dispose();
}

enum _AudioTab { tts, asr }

class AudioScreen extends StatefulWidget {
  static const name = 'Audio';
  static const path = 'audio';

  const AudioScreen({
    this.recorderFactory,
    this.playerFactory,
    this.pickAudioFiles,
    this.saveAudioBytes,
    super.key,
  });

  final AudioScreenAudioRecorderFactory? recorderFactory;
  final AudioScreenAudioPlayerFactory? playerFactory;
  final Future<String?> Function()? pickAudioFiles;
  final Future<void> Function(Uint8List bytes, String filename)? saveAudioBytes;

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  _AudioTab _selectedTab = _AudioTab.tts;

  final TextEditingController _ttsTextController = TextEditingController();
  late final TextEditingController _voiceController;

  AudioScreenAudioPlayer? _player;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<void>? _playerCompleteSub;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;
  Uint8List? _lastLoadedAudioBytes;

  AudioScreenAudioRecorder? _recorder;
  bool _isRecording = false;
  Timer? _recordTimer;
  Duration _recordDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    var initialVoice = AudioSettings.defaultBackplaneTtsVoice;
    try {
      final settings = context.read<AudioSettingsBloc>().state.settings;
      if (settings.ttsVoice.isNotEmpty) {
        initialVoice = settings.ttsVoice;
      }
    } catch (_) {}
    _voiceController = TextEditingController(text: initialVoice);

    try {
      final audioState = context.read<AudioServiceBloc>().state;
      if (audioState.audioBytes != null) {
        _loadAudio(audioState.audioBytes!);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _playerCompleteSub?.cancel();
    _player?.dispose();
    _recordTimer?.cancel();
    _recorder?.dispose();
    _ttsTextController.dispose();
    _voiceController.dispose();
    super.dispose();
  }

  void _initPlayer() {
    if (_player != null) return;
    _player = widget.playerFactory?.call() ?? DefaultAudioScreenAudioPlayer();
    _playerStateSub = _player!.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playerState = state);
    });
    _durationSub = _player!.onDurationChanged.listen((duration) {
      if (!mounted) return;
      if (duration > Duration.zero) {
        setState(() => _duration = duration);
      }
    });
    _positionSub = _player!.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        _position = position;
        if (position > _duration) {
          _duration = position;
        }
      });
    });
    _playerCompleteSub = _player!.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _position = Duration.zero;
        _playerState = PlayerState.completed;
      });
    });
  }

  void _initRecorder() {
    _recorder ??=
        widget.recorderFactory?.call() ?? DefaultAudioScreenAudioRecorder();
  }

  Source _createAudioSource(Uint8List bytes) {
    if (!kIsWeb) {
      try {
        final isWav =
            bytes.length >= 4 &&
            bytes[0] == 0x52 &&
            bytes[1] == 0x49 &&
            bytes[2] == 0x46 &&
            bytes[3] == 0x46;
        final extension = isWav ? 'wav' : 'mp3';
        final mimeType = isWav ? 'audio/wav' : 'audio/mpeg';
        final tempFile = File(
          p.join(Directory.systemTemp.path, 'gsmlg_tts_preview.$extension'),
        );
        tempFile.writeAsBytesSync(bytes, flush: true);
        return DeviceFileSource(tempFile.path, mimeType: mimeType);
      } catch (_) {
        // Fall back to in-memory bytes
      }
    }
    return BytesSource(bytes, mimeType: 'audio/mpeg');
  }

  Future<void> _loadAudio(Uint8List bytes) async {
    _lastLoadedAudioBytes = bytes;
    _position = Duration.zero;
    _initPlayer();
    try {
      final source = _createAudioSource(bytes);
      await _player?.setSource(source);
      final dur = await _player?.getDuration();
      if (dur != null && dur > Duration.zero && mounted) {
        setState(() => _duration = dur);
      }
    } catch (_) {}
  }

  Future<void> _play(Uint8List bytes) async {
    _initPlayer();
    if (_playerState == PlayerState.paused) {
      await _player?.resume();
      return;
    }
    _lastLoadedAudioBytes = bytes;
    final source = _createAudioSource(bytes);
    await _player!.play(source);
    final dur = await _player!.getDuration();
    if (dur != null && dur > Duration.zero && mounted) {
      setState(() => _duration = dur);
    }
  }

  Future<void> _pause() async {
    await _player?.pause();
  }

  Future<void> _stop() async {
    await _player?.stop();
    if (mounted) {
      setState(() {
        _position = Duration.zero;
        _playerState = PlayerState.stopped;
      });
    }
  }

  Future<void> _seek(Duration position) async {
    _initPlayer();
    setState(() => _position = position);
    await _player?.seek(position);
  }

  Future<void> _saveAudio(Uint8List bytes) async {
    const filename = 'audio.mp3';
    if (widget.saveAudioBytes != null) {
      await widget.saveAudioBytes!(bytes, filename);
      return;
    }

    try {
      final location = await getSaveLocation(
        suggestedName: filename,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'MP3 Audio', extensions: ['mp3']),
        ],
      );
      if (location != null) {
        final file = File(location.path);
        await file.writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audio saved to ${file.path}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save audio: $e')));
      }
    }
  }

  Future<void> _toggleRecording() async {
    _initRecorder();
    if (!_isRecording) {
      final hasPerm = await _recorder!.hasPermission();
      if (!hasPerm) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.ttsDatasetMicrophoneDenied)),
          );
        }
        return;
      }
      final tempDir = Directory.systemTemp.path;
      final path = p.join(
        tempDir,
        'asr_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      await _recorder!.start(path: path);
      if (mounted) {
        _recordDuration = Duration.zero;
        _recordTimer?.cancel();
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _recordDuration += const Duration(seconds: 1);
            });
          }
        });
        setState(() => _isRecording = true);
      }
    } else {
      _recordTimer?.cancel();
      _recordTimer = null;
      final recordedPath = await _recorder!.stop();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordDuration = Duration.zero;
        });
      }
      if (recordedPath != null && recordedPath.isNotEmpty) {
        if (mounted) {
          context.read<AudioServiceBloc>().add(
            AudioAsrTranscribeFile(recordedPath),
          );
        }
      }
    }
  }

  Future<void> _pickAudioFile() async {
    if (widget.pickAudioFiles != null) {
      final pickedPath = await widget.pickAudioFiles!();
      if (pickedPath != null && mounted) {
        context.read<AudioServiceBloc>().add(
          AudioAsrTranscribeFile(pickedPath),
        );
      }
      return;
    }

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'flac', 'aac', 'ogg', 'opus'],
      );
      if (!mounted || files.isEmpty) return;
      final file = files.first;
      if (file.path != null && file.path!.isNotEmpty) {
        context.read<AudioServiceBloc>().add(
          AudioAsrTranscribeFile(file.path!),
        );
      } else {
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        context.read<AudioServiceBloc>().add(
          AudioAsrTranscribeBytes(bytes, filename: file.name),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick file: $e')));
      }
    }
  }

  Future<void> _copyTranscription(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.audioCopySuccess)));
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppAdaptiveScaffold(
      navigationRestoreInHeader: true,
      selectedIndex: Destinations.indexOf(
        const Key(ServiceScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (_) => SafeArea(
        child: CustomScrollView(
          slivers: [
            DmNavigationHeader(
              builder: (context, header) => SliverAppBar(
                leading: header.leading,
                leadingWidth: header.leadingWidth,
                automaticallyImplyLeading: header.automaticallyImplyLeading,
                floating: true,
                title: Text(context.l10n.audioServiceTitle),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => context.goNamed(AudioSettingsScreen.name),
                    tooltip: context.l10n.audioSettingsTitle,
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(Constants.defaultGridGap),
              sliver: SliverToBoxAdapter(
                child: BlocConsumer<AudioServiceBloc, AudioServiceState>(
                  listener: (context, state) {
                    if (state.audioBytes != null &&
                        state.audioBytes != _lastLoadedAudioBytes) {
                      _loadAudio(state.audioBytes!);
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SegmentedButton<_AudioTab>(
                          segments: [
                            ButtonSegment(
                              value: _AudioTab.tts,
                              label: Text(context.l10n.audioTtsTab),
                              icon: const Icon(Icons.record_voice_over),
                            ),
                            ButtonSegment(
                              value: _AudioTab.asr,
                              label: Text(context.l10n.audioAsrTab),
                              icon: const Icon(Icons.mic),
                            ),
                          ],
                          selected: {_selectedTab},
                          onSelectionChanged: (selected) {
                            setState(() => _selectedTab = selected.first);
                          },
                        ),
                        const SizedBox(height: 20),
                        if (_selectedTab == _AudioTab.tts)
                          _buildTtsView(context, state)
                        else
                          _buildAsrView(context, state),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTtsView(
    BuildContext context,
    AudioServiceState state,
  ) {
    final effectiveDuration = _duration > _position ? _duration : _position;
    final maxDurationMs = effectiveDuration.inMilliseconds.toDouble();
    final currentPositionMs = _position.inMilliseconds.toDouble().clamp(
      0.0,
      maxDurationMs > 0 ? maxDurationMs : 0.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.ttsError != null) ...[
          _buildErrorBanner(context, state.ttsError!),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _ttsTextController,
          minLines: 3,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: context.l10n.audioTextInputHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '${context.l10n.audioVoiceLabel}:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 180,
              child: TextField(
                controller: _voiceController,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: context.l10n.audioVoiceLabel,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (state.ttsStatus == TtsStatus.synthesizing) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(context.l10n.audioSynthesizing),
            ] else ...[
              FilledButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: Text(context.l10n.audioSynthesizeButton),
                onPressed: () {
                  final text = _ttsTextController.text.trim();
                  final voice = _voiceController.text.trim();
                  if (text.isNotEmpty) {
                    context.read<AudioServiceBloc>().add(
                      AudioTtsSynthesize(
                        text,
                        voice: voice.isNotEmpty ? voice : null,
                      ),
                    );
                  }
                },
              ),
            ],
          ],
        ),
        if (state.audioBytes != null || state.ttsStatus == TtsStatus.ready) ...[
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        tooltip: context.l10n.audioPlayButton,
                        onPressed: state.audioBytes != null
                            ? () => _play(state.audioBytes!)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.pause),
                        tooltip: context.l10n.audioPauseButton,
                        onPressed: _pause,
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        tooltip: context.l10n.audioStopButton,
                        onPressed: _stop,
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.download),
                        label: Text(context.l10n.audioSaveButton),
                        onPressed: state.audioBytes != null
                            ? () => _saveAudio(state.audioBytes!)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(_formatDuration(_position)),
                      Expanded(
                        child: Slider(
                          value: maxDurationMs > 0 ? currentPositionMs : 0.0,
                          min: 0.0,
                          max: maxDurationMs > 0 ? maxDurationMs : 1.0,
                          onChanged: maxDurationMs > 0
                              ? (val) =>
                                    _seek(Duration(milliseconds: val.round()))
                              : null,
                        ),
                      ),
                      Text(_formatDuration(effectiveDuration)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAsrView(BuildContext context, AudioServiceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.asrError != null) ...[
          _buildErrorBanner(context, state.asrError!),
          const SizedBox(height: 16),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              style: _isRecording
                  ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    )
                  : null,
              label: Text(
                _isRecording
                    ? context.l10n.audioStopRecordButton
                    : context.l10n.audioRecordButton,
              ),
              onPressed: state.asrStatus == AsrStatus.transcribing
                  ? null
                  : _toggleRecording,
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: Text(context.l10n.audioUploadButton),
              onPressed:
                  state.asrStatus == AsrStatus.transcribing || _isRecording
                  ? null
                  : _pickAudioFile,
            ),
          ],
        ),
        if (_isRecording) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fiber_manual_record,
                      color: Theme.of(context).colorScheme.error,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recording ${_formatDuration(_recordDuration)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        if (state.asrStatus == AsrStatus.transcribing) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.audioTranscribing,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
        if (state.transcription != null && state.transcription!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.audioTranscriptionResult,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            tooltip: 'Copy',
                            onPressed: () =>
                                _copyTranscription(state.transcription!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: context.l10n.audioClear,
                            onPressed: () {
                              context.read<AudioServiceBloc>().add(
                                const AudioAsrClear(),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    state.transcription!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
