import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xterm/session_isolate_probes.dart';
import 'package:xterm/src/ui/painter.dart';
import 'package:xterm/xterm.dart';

CellData cell(
  int glyph, {
  int foreground = CellColor.normal,
  int background = CellColor.normal,
  int flags = 0,
  int width = 1,
}) =>
    CellData(
      foreground: foreground,
      background: background,
      flags: flags,
      content: glyph | (width << CellContent.widthShift),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('paragraph identity uses the painted color and shaping attributes', () {
    const red = CellColor.rgb | 0xf23467;
    const blue = CellColor.rgb | 0x014abc;
    expect(
      paragraphPaintKey(cell(0x41, foreground: red, background: blue)),
      paragraphPaintKey(cell(0x41, foreground: red, background: red, width: 2)),
    );
    expect(
      paragraphPaintKey(cell(0x41,
          foreground: red, background: blue, flags: CellFlags.inverse)),
      paragraphPaintKey(cell(0x41,
          foreground: blue, background: blue, flags: CellFlags.inverse)),
    );
    final distinct = [
      cell(0x41, foreground: red),
      cell(0x41, foreground: blue),
      cell(0x41, foreground: red, flags: CellFlags.faint),
      cell(0x41, foreground: red, flags: CellFlags.bold),
      cell(0x41, foreground: red, flags: CellFlags.italic),
      cell(0x41, foreground: red, flags: CellFlags.underline),
      cell(0x41, background: red, flags: CellFlags.inverse),
      cell(0x41, foreground: CellColor.palette | 0x7f),
      cell(0x41, background: CellColor.normal, flags: CellFlags.inverse),
      cell(0x41),
      cell(0x754c, foreground: red, width: 2),
      cell(0x0301, foreground: red),
      cell(0x10ffff,
          foreground: CellColor.rgb | 0xffffff,
          flags: CellFlags.inverse | CellFlags.underline),
    ];
    final keys = distinct.map(paragraphPaintKey).toList();
    expect(keys.toSet(), hasLength(distinct.length));
    expect(keys.every((key) => key >= 0 && key <= 9007199254740991), isTrue);
  });

  test('glyph diagnostic splits paragraph work and retains cache behavior', () {
    final painter = TerminalPainter(
      theme: TerminalThemes.defaultTheme,
      textStyle: const TerminalStyle(),
      textScaler: TextScaler.noScaling,
      normalizedParagraphKeys: true,
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    GlyphPaintCounters? recorded;
    TerminalIsolateProbes.observer = (_, __) {};
    TerminalIsolateProbes.glyphObserver = (frame) => recorded = frame;
    final frame = TerminalIsolateProbes.beginGlyphFrame();
    try {
      painter.paintCellForeground(canvas, Offset.zero, cell(0x754c, width: 2));
      painter.paintCellForeground(canvas, const Offset(60, 0),
          cell(0x754c, width: 2, background: CellColor.rgb | 0xff));
    } finally {
      TerminalIsolateProbes.endGlyphFrame(frame);
      TerminalIsolateProbes.glyphObserver = null;
      TerminalIsolateProbes.observer = null;
      recorder.endRecording().dispose();
    }
    expect(recorded?.misses, 1);
    expect(recorded?.hits, 1);
    expect(recorded?.paragraphDraws, 2);
    expect(recorded!.paragraphBuildMicros + recorded!.nativeLayoutMicros,
        lessThanOrEqualTo(recorded!.layoutMicros));
  });

  test('normalized and baseline painting agree after style and cache changes',
      () async {
    const red = CellColor.rgb | 0xf01020;
    const blue = CellColor.rgb | 0x001fce;
    final cells = [
      cell(0x41, foreground: red, background: blue),
      cell(0x41, foreground: red, background: red),
      cell(0x41, background: blue, flags: CellFlags.inverse),
      cell(0x41, background: red, flags: CellFlags.inverse | CellFlags.faint),
      cell(0x20, foreground: blue, flags: CellFlags.underline),
      cell(0x4e2d,
          foreground: CellColor.palette | 120, width: 2, flags: CellFlags.bold),
      cell(0x0301, foreground: CellColor.named | 1, flags: CellFlags.italic),
      cell(0x41, flags: CellFlags.inverse),
      cell(0x41),
    ];

    Future<List<List<int>>> paint(bool normalized) async {
      final painter = TerminalPainter(
          theme: TerminalThemes.defaultTheme,
          textStyle: const TerminalStyle(fontSize: 14),
          textScaler: TextScaler.noScaling,
          normalizedParagraphKeys: normalized);
      final frames = <List<int>>[];
      for (var stage = 0; stage < 4; stage++) {
        if (stage == 1) painter.theme = TerminalThemes.whiteOnBlack;
        if (stage == 2) painter.textStyle = const TerminalStyle(fontSize: 21);
        if (stage == 3) painter.textScaler = const TextScaler.linear(1.4);
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        for (var index = 0; index < cells.length; index++) {
          painter.paintCell(canvas, Offset(index * 36, 6), cells[index]);
        }
        final picture = recorder.endRecording();
        final image = await picture.toImage(350, 56);
        final pixels = (await image.toByteData())!.buffer.asUint8List();
        frames.add(pixels);
        image.dispose();
        picture.dispose();
      }
      return frames;
    }

    final baseline = await paint(false);
    final normalized = await paint(true);
    expect(normalized, baseline);
  });
}
