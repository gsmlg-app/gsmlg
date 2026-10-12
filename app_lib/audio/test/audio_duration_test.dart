import 'dart:typed_data';

import 'package:app_audio/audio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseAudioDuration', () {
    test('returns null for empty or too short bytes', () {
      expect(parseAudioDuration(Uint8List(0)), isNull);
      expect(parseAudioDuration(Uint8List.fromList([1, 2, 3])), isNull);
    });

    test('parses WAV file header duration accurately', () {
      // Create a minimal valid WAV buffer
      // 44-byte WAV header:
      // RIFF (4) + chunkSize (4) + WAVE (4)
      // fmt  (4) + fmtSize (4) + format(2) + channels(2) + sampleRate(4) + byteRate(4) + blockAlign(2) + bitsPerSample(2)
      // data (4) + dataSize (4)
      final sampleRate = 16000;
      final channels = 1;
      final bitsPerSample = 16;
      final byteRate =
          sampleRate * channels * (bitsPerSample ~/ 8); // 32000 bytes/sec
      final durationSeconds = 3;
      final dataSize = byteRate * durationSeconds; // 96000 bytes
      final riffSize = 36 + dataSize;

      final buffer = ByteData(44 + 10);
      // RIFF
      buffer.setUint8(0, 0x52);
      buffer.setUint8(1, 0x49);
      buffer.setUint8(2, 0x46);
      buffer.setUint8(3, 0x46);
      buffer.setUint32(4, riffSize, Endian.little);
      // WAVE
      buffer.setUint8(8, 0x57);
      buffer.setUint8(9, 0x41);
      buffer.setUint8(10, 0x56);
      buffer.setUint8(11, 0x45);
      // fmt
      buffer.setUint8(12, 0x66);
      buffer.setUint8(13, 0x6D);
      buffer.setUint8(14, 0x74);
      buffer.setUint8(15, 0x20);
      buffer.setUint32(16, 16, Endian.little); // fmt size
      buffer.setUint16(20, 1, Endian.little); // PCM format
      buffer.setUint16(22, channels, Endian.little);
      buffer.setUint32(24, sampleRate, Endian.little);
      buffer.setUint32(28, byteRate, Endian.little);
      buffer.setUint16(32, 2, Endian.little); // block align
      buffer.setUint16(34, bitsPerSample, Endian.little);
      // data
      buffer.setUint8(36, 0x64);
      buffer.setUint8(37, 0x61);
      buffer.setUint8(38, 0x74);
      buffer.setUint8(39, 0x61);
      buffer.setUint32(40, dataSize, Endian.little);

      final wavBytes = buffer.buffer.asUint8List();
      final duration = parseAudioDuration(wavBytes);
      expect(duration, isNotNull);
      expect(duration!.inSeconds, 3);
      expect(duration.inMilliseconds, 3000);
    });

    test('parses MP3 Xing/Info header frame count duration accurately', () {
      // Minimal MP3 frame with Xing header
      // MPEG-1 Layer III, 128 kbps, 44100 Hz, stereo
      // Frame size = 144 * 128000 / 44100 = 417 bytes
      // Xing offset in stereo = 4 + 32 = 36
      final frameBytes = Uint8List(500);
      // MPEG frame sync (0xFF, 0xFB) -> MPEG-1, Layer III, no CRC
      frameBytes[0] = 0xFF;
      frameBytes[1] = 0xFB;
      // bitrate index = 9 (128 kbps = 1001b = 0x90), sample rate index = 0 (44100 Hz = 00b = 0x00)
      frameBytes[2] = 0x90;
      frameBytes[3] = 0x00; // stereo

      // Xing header at offset 36
      frameBytes[36] = 0x58; // 'X'
      frameBytes[37] = 0x69; // 'i'
      frameBytes[38] = 0x6E; // 'n'
      frameBytes[39] = 0x67; // 'g'
      // Flags at offset 40: 0x00000001 (FRAMES flag present)
      frameBytes[43] = 0x01;
      // Frames count at offset 44 (4 bytes big-endian)
      // Say 153 frames at 1152 samples/frame = 176256 samples / 44100 = 3.996s (~4000ms)
      final frames = 153;
      final byteData = ByteData.sublistView(frameBytes);
      byteData.setUint32(44, frames, Endian.big);

      final duration = parseAudioDuration(frameBytes);
      expect(duration, isNotNull);
      expect(duration!.inMilliseconds, 3996);
    });
  });
}
