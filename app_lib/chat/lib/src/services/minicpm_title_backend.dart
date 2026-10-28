import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:lib_llama_cpp_platform_interface/lib_llama_cpp_platform_interface.dart';
import 'package:lib_llama_cpp_server/lib_llama_cpp_server.dart';
import 'package:path/path.dart' as p;

import 'conversation_title_generator.dart';

const titleModelFilename = 'MiniCPM5-1B-Q4_K_M.gguf';
const titleModelSha256 =
    '81b64d05a23b17b34c475f42b3e72fbde62d4b92cc34541f7a8031d0752deafa';
const titleModelAsset = 'assets/models/conversation_title/$titleModelFilename';

/// Resolves installed weights without reading them into the Dart heap. Android
/// must stream-extract its APK asset because this runtime takes a file path.
Future<String> bundledTitleModelPath() async {
  if (Platform.isAndroid || Platform.isIOS) {
    return (await MethodChannel(
      Platform.isIOS
          ? 'app_local_llm_ios/service'
          : 'app_local_llm_android/service',
    ).invokeMethod<String>('prepareTitleModel'))!;
  }
  final executable = File(Platform.resolvedExecutable).parent.path;
  final assets = Platform.isMacOS
      ? p.join(
          executable,
          '../Frameworks/App.framework/Resources/flutter_assets',
        )
      : p.join(executable, 'data/flutter_assets');
  return p.normalize(p.join(assets, titleModelAsset));
}

/// One short-lived worker owns a separate CPU engine. Native loading, hashing,
/// polling and teardown all happen off the UI isolate. No HTTP/network client.
class MiniCpmTitleBackend implements ConversationTitleBackend {
  MiniCpmTitleBackend({this.modelPath, this.libraryPath});
  final String? modelPath;
  final String? libraryPath;
  SendPort? _commands;
  Future<void>? _running;
  bool _cancelled = false;

  @override
  Future<String> infer(List<Map<String, Object?>> messages) async {
    if (_running != null) throw StateError('Title backend already busy');
    final done = Completer<void>();
    _running = done.future;
    _cancelled = false;
    final replies = ReceivePort();
    Isolate? worker;
    try {
      final path = modelPath ?? await bundledTitleModelPath();
      String? library = libraryPath;
      var resolution = LlamaCppLibraryResolution.path;
      if (library == null) {
        final descriptor = await LibLlamaCppPlatform.instance.resolveLibrary();
        resolution = descriptor.resolution;
        library = descriptor.path ?? descriptor.lookupName;
      }
      if (_cancelled) throw StateError('Cancelled');
      worker = await Isolate.spawn(
        _titleWorker,
        [replies.sendPort, path, library, resolution.name, messages],
        onError: replies.sendPort,
        onExit: replies.sendPort,
      );
      await for (final reply in replies) {
        if (reply is SendPort) {
          _commands = reply;
          if (_cancelled) reply.send('cancel');
        } else if (reply is Map && reply['title'] is String) {
          if (_cancelled) throw StateError('Cancelled');
          return reply['title'] as String;
        } else {
          throw StateError('Title inference failed');
        }
      }
      throw StateError('Title worker exited');
    } finally {
      _commands = null;
      // Worker sends its result only after native teardown has completed.
      worker?.kill(priority: Isolate.beforeNextEvent);
      replies.close();
      _running = null;
      done.complete();
    }
  }

  @override
  Future<void> cancel() async {
    _cancelled = true;
    _commands?.send('cancel');
    await _running;
  }

  @override
  Future<void> dispose() => cancel();
}

Future<void> _titleWorker(List<Object?> arguments) async {
  final reply = arguments[0] as SendPort;
  final commands = ReceivePort();
  var cancelled = false;
  final subscription = commands.listen((_) => cancelled = true);
  reply.send(commands.sendPort);
  LlcsEngine? engine;
  String? title;
  try {
    final file = File(arguments[1] as String);
    if (await file.length() != 688065920 ||
        (await sha256.bind(file.openRead()).first).toString() !=
            titleModelSha256) {
      throw StateError('Bundled title model missing or checksum invalid');
    }
    if (cancelled) return;
    final library = switch (arguments[3]) {
      'process' => DynamicLibrary.process(),
      'executable' => DynamicLibrary.executable(),
      _ => DynamicLibrary.open(arguments[2] as String),
    };
    engine = LlcsEngine.open(
      library: library,
      config: LlcsEngineConfig(
        modelPath: file.path,
        nCtx: 2048,
        nGpuLayers: 0,
        nParallel: 1,
        nThreads: 4,
        nThreadsBatch: 4,
        nBatch: 128,
        nUbatch: 64,
        useJinja: true,
      ),
    );
    final task = engine.submit({
      'messages': arguments[4],
      'stream': true,
      'max_tokens': 64,
      'temperature': 0.0,
      'seed': 42,
      'enable_thinking': false,
      'chat_template_kwargs': {'enable_thinking': false},
    });
    final output = StringBuffer();
    final deadline = DateTime.now().add(const Duration(seconds: 45));
    var finished = false;
    while (!cancelled && DateTime.now().isBefore(deadline)) {
      final event = engine.poll(
        task,
        timeout: const Duration(milliseconds: 10),
      );
      if (event == null) break;
      if (event['error'] != null) {
        throw StateError('Native title inference failed');
      }
      for (final choice in (event['choices'] as List? ?? const [])) {
        final delta = choice['delta'];
        if (delta is Map && delta['content'] is String) {
          output.write(delta['content']);
        }
        if (choice['finish_reason'] == 'stop') finished = true;
      }
      await Future<void>.delayed(Duration.zero);
    }
    if (cancelled || !finished) {
      engine.cancel(task);
    } else {
      title = output.toString();
    }
  } catch (error) {
    developer.log(
      'Native title inference failed (${error.runtimeType})',
      name: 'app_chat.title',
    );
  } finally {
    engine?.close();
    await subscription.cancel();
    commands.close();
    reply.send({'title': title});
  }
}
