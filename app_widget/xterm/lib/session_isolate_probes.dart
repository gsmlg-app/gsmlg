import 'dart:developer' as developer;

/// Opt-in native profiling observer, unset by the production application.
abstract final class TerminalIsolateProbes {
  static void Function(String stage, int elapsedMicros)? observer;
  static void Function(GlyphPaintCounters)? glyphObserver;
  static GlyphPaintCounters? activeGlyphFrame;

  /// Optional comparison override for the isolate painter, set before mount.
  static bool? normalizedParagraphKeysForBenchmark;

  static GlyphPaintCounters? beginGlyphFrame() =>
      activeGlyphFrame = glyphObserver == null ? null : GlyphPaintCounters();

  static void endGlyphFrame(GlyphPaintCounters? frame) {
    activeGlyphFrame = null;
    if (frame != null) glyphObserver?.call(frame);
  }

  static int timestamp() => developer.Timeline.now;

  static int? start() => observer == null ? null : timestamp();

  static int elapsed(int started) => developer.Timeline.now - started;

  static void finish(String stage, int? started) {
    if (started != null) {
      observer?.call(stage, developer.Timeline.now - started);
    }
  }
}

final class GlyphPaintCounters {
  int rows = 0;
  int hits = 0;
  int misses = 0;
  int evictions = 0;
  int layoutMicros = 0;
  int paragraphBuildMicros = 0;
  int nativeLayoutMicros = 0;
  int paragraphDraws = 0;
  int backgroundDraws = 0;
}
