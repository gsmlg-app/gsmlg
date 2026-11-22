import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A file or image payload read from the OS clipboard.
final class ClipboardAttachmentData {
  const ClipboardAttachmentData({
    required this.name,
    required this.bytes,
    this.mimeType,
    this.sizeBytes,
  });

  final String name;
  final Uint8List bytes;
  final String? mimeType;
  final int? sizeBytes;
}

/// Result of normalizing an oversized image into a compact upload payload.
final class NormalizedImageData {
  const NormalizedImageData({
    required this.bytes,
    required this.mimeType,
    required this.extension,
  });

  final Uint8List bytes;
  final String mimeType;
  final String extension;
}

/// Reads copied files and images from the platform clipboard via the
/// `gsmlg/clipboard` native channel.
abstract final class ClipboardAttachments {
  static const _channel = MethodChannel('gsmlg/clipboard');

  /// Test hook overriding native clipboard reads.
  @visibleForTesting
  static Future<List<ClipboardAttachmentData>> Function()? readerOverride;

  /// Test hook overriding native image normalization.
  @visibleForTesting
  static Future<NormalizedImageData?> Function(
    Uint8List bytes, {
    int maxDimension,
    int quality,
    int maxBytes,
  })?
  normalizerOverride;

  /// Replaces [name]'s file extension with [newExtension] (without leading dot).
  static String replaceExtension(String name, String newExtension) {
    final dot = name.lastIndexOf('.');
    if (dot > 0 && dot < name.length - 1) {
      return '${name.substring(0, dot)}.$newExtension';
    }
    return '$name.$newExtension';
  }

  /// Downscales and JPEG-compresses oversized images via the native platform
  /// bridge. Returns `null` when the image is already compact or normalization
  /// is unavailable on the current platform.
  static Future<NormalizedImageData?> normalizeImage(
    Uint8List bytes, {
    int maxDimension = 1568,
    int quality = 82,
    int maxBytes = 512 * 1024,
  }) async {
    final override = normalizerOverride;
    if (override != null) {
      return override(
        bytes,
        maxDimension: maxDimension,
        quality: quality,
        maxBytes: maxBytes,
      );
    }
    if (bytes.isEmpty) return null;
    try {
      final raw = await _channel
          .invokeMapMethod<String, dynamic>('normalizeImage', {
            'bytes': bytes,
            'maxDimension': maxDimension,
            'quality': quality,
            'maxBytes': maxBytes,
          });
      if (raw == null) return null;
      final outBytes = raw['bytes'];
      final mimeType = raw['mimeType']?.toString();
      final ext = raw['extension']?.toString();
      if (outBytes is! Uint8List ||
          mimeType == null ||
          mimeType.isEmpty ||
          ext == null ||
          ext.isEmpty) {
        return null;
      }
      return NormalizedImageData(
        bytes: outBytes,
        mimeType: mimeType,
        extension: ext,
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Returns copied files or images currently on the clipboard, or an empty
  /// list when only plain text is present or the platform has no bridge.
  static Future<List<ClipboardAttachmentData>> read() async {
    final override = readerOverride;
    if (override != null) {
      return override();
    }
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>('readAttachments');
      if (raw == null || raw.isEmpty) return const [];
      final results = <ClipboardAttachmentData>[];
      for (final entry in raw) {
        if (entry is! Map) continue;
        final name = entry['name']?.toString();
        final rawBytes = entry['bytes'];
        if (name == null || name.isEmpty || rawBytes is! Uint8List) continue;
        results.add(
          ClipboardAttachmentData(
            name: name,
            bytes: rawBytes,
            mimeType: entry['mimeType']?.toString(),
            sizeBytes: (entry['sizeBytes'] as num?)?.toInt() ?? rawBytes.length,
          ),
        );
      }
      return results;
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }
}
