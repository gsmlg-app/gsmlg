import 'dart:typed_data';

/// Parses the duration of an audio buffer in MP3 or WAV format.
/// Returns null if the format is unsupported or invalid.
Duration? parseAudioDuration(Uint8List bytes) {
  if (bytes.length < 12) return null;

  // Check for WAV (RIFF....WAVE)
  if (bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x41 &&
      bytes[10] == 0x56 &&
      bytes[11] == 0x45) {
    return _parseWavDuration(bytes);
  }

  // Check for MP3
  return _parseMp3Duration(bytes);
}

Duration? _parseWavDuration(Uint8List bytes) {
  var offset = 12;
  var byteRate = 0;
  var dataSize = 0;

  while (offset + 8 <= bytes.length) {
    final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final chunkSize =
        bytes[offset + 4] |
        (bytes[offset + 5] << 8) |
        (bytes[offset + 6] << 16) |
        (bytes[offset + 7] << 24);
    offset += 8;

    if (chunkId == 'fmt ' && offset + 12 <= bytes.length) {
      byteRate =
          bytes[offset + 8] |
          (bytes[offset + 9] << 8) |
          (bytes[offset + 10] << 16) |
          (bytes[offset + 11] << 24);
    } else if (chunkId == 'data') {
      dataSize = chunkSize;
      break;
    }

    offset += chunkSize;
    if (chunkSize.isOdd) offset += 1;
  }

  if (byteRate > 0 && dataSize > 0) {
    return Duration(milliseconds: (dataSize * 1000) ~/ byteRate);
  }
  return null;
}

Duration? _parseMp3Duration(Uint8List bytes) {
  var offset = 0;

  // Skip ID3v2 tag if present
  if (bytes.length >= 10 &&
      bytes[0] == 0x49 &&
      bytes[1] == 0x44 &&
      bytes[2] == 0x33) {
    final tagSize =
        ((bytes[6] & 0x7F) << 21) |
        ((bytes[7] & 0x7F) << 14) |
        ((bytes[8] & 0x7F) << 7) |
        (bytes[9] & 0x7F);
    offset = 10 + tagSize;
    // Check for footer presence
    if ((bytes[5] & 0x10) != 0) {
      offset += 10;
    }
  }

  const mpeg1Layer3Bitrates = [
    0,
    32,
    40,
    48,
    56,
    64,
    80,
    96,
    112,
    128,
    160,
    192,
    224,
    256,
    320,
    0,
  ];
  const mpeg2Layer3Bitrates = [
    0,
    8,
    16,
    24,
    32,
    40,
    48,
    56,
    64,
    80,
    96,
    112,
    128,
    144,
    160,
    0,
  ];

  const mpeg1SampleRates = [44100, 48000, 32000, 0];
  const mpeg2SampleRates = [22050, 24000, 16000, 0];
  const mpeg25SampleRates = [11025, 12000, 8000, 0];

  var totalSamples = 0;
  var sampleRate = 0;
  var firstFrameBitrate = 0;
  var firstFrameOffset = -1;

  while (offset + 4 <= bytes.length) {
    if (bytes[offset] == 0xFF && (bytes[offset + 1] & 0xE0) == 0xE0) {
      final b1 = bytes[offset + 1];
      final b2 = bytes[offset + 2];
      final b3 = bytes[offset + 3];

      final versionBits = (b1 >> 3) & 0x03; // 3 = MPEG1, 2 = MPEG2, 0 = MPEG2.5
      final layerBits = (b1 >> 1) & 0x03; // 1 = Layer III
      final bitrateIndex = (b2 >> 4) & 0x0F;
      final sampleRateIndex = (b2 >> 2) & 0x03;
      final padding = (b2 >> 1) & 0x01;
      final channelMode = (b3 >> 6) & 0x03;

      if (versionBits != 1 &&
          layerBits == 1 &&
          bitrateIndex > 0 &&
          bitrateIndex < 15 &&
          sampleRateIndex < 3) {
        final isMpeg1 = versionBits == 3;
        final isMpeg2 = versionBits == 2;
        final currentSampleRate = isMpeg1
            ? mpeg1SampleRates[sampleRateIndex]
            : (isMpeg2
                  ? mpeg2SampleRates[sampleRateIndex]
                  : mpeg25SampleRates[sampleRateIndex]);
        final bitrate = isMpeg1
            ? mpeg1Layer3Bitrates[bitrateIndex]
            : mpeg2Layer3Bitrates[bitrateIndex];

        if (currentSampleRate > 0 && bitrate > 0) {
          sampleRate = currentSampleRate;
          final samplesPerFrame = isMpeg1 ? 1152 : 576;
          final frameSize = isMpeg1
              ? ((144 * bitrate * 1000) ~/ currentSampleRate) + padding
              : ((72 * bitrate * 1000) ~/ currentSampleRate) + padding;

          if (frameSize <= 0) {
            offset++;
            continue;
          }

          if (firstFrameOffset < 0) {
            firstFrameOffset = offset;
            firstFrameBitrate = bitrate;

            final xingOffset = isMpeg1
                ? (channelMode == 3 ? 21 : 36)
                : (channelMode == 3 ? 13 : 21);
            final xingIndex = offset + xingOffset;

            if (xingIndex + 12 <= bytes.length) {
              final headerTag = String.fromCharCodes(
                bytes.sublist(xingIndex, xingIndex + 4),
              );
              if (headerTag == 'Xing' || headerTag == 'Info') {
                final flags =
                    (bytes[xingIndex + 4] << 24) |
                    (bytes[xingIndex + 5] << 16) |
                    (bytes[xingIndex + 6] << 8) |
                    bytes[xingIndex + 7];
                if ((flags & 0x01) != 0) {
                  final frames =
                      (bytes[xingIndex + 8] << 24) |
                      (bytes[xingIndex + 9] << 16) |
                      (bytes[xingIndex + 10] << 8) |
                      bytes[xingIndex + 11];
                  if (frames > 0) {
                    final durationMs =
                        (frames * samplesPerFrame * 1000) ~/ currentSampleRate;
                    return Duration(milliseconds: durationMs);
                  }
                }
              }
            }
          }

          totalSamples += samplesPerFrame;
          offset += frameSize;
          continue;
        }
      }
    }
    offset++;
  }

  if (sampleRate > 0 && totalSamples > 0) {
    return Duration(milliseconds: (totalSamples * 1000) ~/ sampleRate);
  }

  if (firstFrameOffset >= 0 && firstFrameBitrate > 0) {
    final audioBytesCount = bytes.length - firstFrameOffset;
    final durationMs =
        ((audioBytesCount * 8 * 1000) / (firstFrameBitrate * 1000)).round();
    return Duration(milliseconds: durationMs);
  }

  return null;
}
