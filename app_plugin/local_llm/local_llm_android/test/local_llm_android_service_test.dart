import 'package:app_local_llm_android/local_llm_android.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('app_local_llm_android/service');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('startService invokes the native Android service channel', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });

    await LocalLlmAndroid().startService();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'startService');
    expect(calls.single.arguments, {
      'title': 'Local LLM',
      'message': 'Local model is running.',
    });
  });

  test('stopService invokes the native Android service channel', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });

    await LocalLlmAndroid().stopService();

    expect(calls, hasLength(1));
    expect(calls.single.method, 'stopService');
  });
}
