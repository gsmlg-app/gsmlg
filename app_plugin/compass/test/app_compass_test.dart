import 'dart:async';
import 'package:app_compass/app_compass.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const codec = StandardMethodCodec();
  const events = MethodChannel('app_compass/events');
  const methods = MethodChannel('app_compass');
  late List<String> calls;

  setUp(() {
    calls = [];
    binding.defaultBinaryMessenger.setMockMethodCallHandler(events, (
      call,
    ) async {
      calls.add(call.method);
      return null;
    });
    binding.defaultBinaryMessenger.setMockMethodCallHandler(methods, (
      call,
    ) async {
      calls.add(call.method);
      return null;
    });
  });
  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(events, null);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(methods, null);
  });

  Future<void> emit(Object? event) async {
    final delivered = Completer<void>();
    binding.channelBuffers.push(
      'app_compass/events',
      codec.encodeSuccessEnvelope(event),
      (_) => delivered.complete(),
    );
    await delivered.future;
    await Future<void>.delayed(Duration.zero);
  }

  test('creating a source or reading its stream does not start sensors', () {
    final source = AppCompass();
    expect(source.readings.isBroadcast, isTrue);
    expect(identical(source.readings, source.readings), isTrue);
    expect(calls, isEmpty);
  });

  test(
    'two listeners share native demand and final cancel stops sensors',
    () async {
      final source = AppCompass();
      final first = <CompassReading>[];
      final second = <CompassReading>[];
      final subscription1 = source.readings.listen(first.add);
      final subscription2 = source.readings.listen(second.add);
      await Future<void>.delayed(Duration.zero);
      expect(calls, ['listen']);
      await emit({'status': 'ready', 'magneticHeadingDegrees': 42.0});
      expect(first.single.magneticHeadingDegrees, 42);
      expect(second.single.magneticHeadingDegrees, 42);
      await subscription1.cancel();
      expect(calls, ['listen']);
      await subscription2.cancel();
      expect(calls, ['listen', 'cancel']);
      final subscription3 = source.readings.listen((_) {});
      await Future<void>.delayed(Duration.zero);
      expect(calls, ['listen', 'cancel', 'listen']);
      await subscription3.cancel();
      expect(calls.last, 'cancel');
    },
  );

  test('orientation refresh does not add a sensor subscription', () async {
    await AppCompass().refreshOrientation();
    expect(calls, ['refreshOrientation']);
  });

  test('invalid native readings propagate as errors', () async {
    final result = AppCompass().readings.first;
    final assertion = expectLater(result, throwsFormatException);
    await Future<void>.delayed(Duration.zero);
    await emit({'status': 'ready', 'magneticHeadingDegrees': -1});
    await assertion;
    expect(calls.last, 'cancel');
  });
}
