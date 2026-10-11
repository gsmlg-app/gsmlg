part of 'bloc.dart';

@immutable
sealed class AudioServiceEvent extends Equatable {
  const AudioServiceEvent();

  @override
  List<Object?> get props => [];
}

@immutable
final class AudioTtsSynthesize extends AudioServiceEvent {
  const AudioTtsSynthesize(this.text, {this.voice, this.model});

  final String text;
  final String? voice;
  final String? model;

  @override
  List<Object?> get props => [text, voice, model];
}

@immutable
final class AudioTtsSetAudioBytes extends AudioServiceEvent {
  const AudioTtsSetAudioBytes(this.bytes);

  final Uint8List? bytes;

  @override
  List<Object?> get props => [bytes];
}

@immutable
final class AudioTtsClear extends AudioServiceEvent {
  const AudioTtsClear();
}

@immutable
final class AudioAsrTranscribeFile extends AudioServiceEvent {
  const AudioAsrTranscribeFile(this.filePath);

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

@immutable
final class AudioAsrTranscribeBytes extends AudioServiceEvent {
  const AudioAsrTranscribeBytes(this.bytes, {this.filename});

  final List<int> bytes;
  final String? filename;

  @override
  List<Object?> get props => [bytes, filename];
}

@immutable
final class AudioAsrClear extends AudioServiceEvent {
  const AudioAsrClear();
}
