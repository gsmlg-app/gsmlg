import 'dart:io';

import 'package:app_chat/app_chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void main() {
  late PathProviderPlatform previousPathProvider;
  late Directory cacheDir;

  setUp(() async {
    previousPathProvider = PathProviderPlatform.instance;
    cacheDir = await Directory.systemTemp.createTemp('gsmlg_model_cache_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(cacheDir.path);
  });

  tearDown(() async {
    PathProviderPlatform.instance = previousPathProvider;
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  });

  test(
    'moves Android file_picker cache imports into the model cache',
    () async {
      final repository = GemmaRepository();
      addTearDown(repository.dispose);

      const modelBytes = 'complete model';
      final info = GemmaModelInfo.defaultModel;
      final source = File(
        p.join(cacheDir.path, 'file_picker', 'picked', info.downloadFileName),
      );
      source.parent.createSync(recursive: true);
      source.writeAsStringSync(modelBytes);

      await repository.importModelFromFile(info: info, sourcePath: source.path);

      final destination = File(await repository.modelFilePath(info));
      expect(source.existsSync(), isFalse);
      expect(destination.readAsStringSync(), modelBytes);
      expect(File('${destination.path}.importing').existsSync(), isFalse);
      expect(File('${destination.path}.backup').existsSync(), isFalse);
      expect(await repository.listInstalledModels(), contains(info.id));
    },
  );

  test('copies external imports through a staging file', () async {
    final repository = GemmaRepository();
    addTearDown(repository.dispose);

    const modelBytes = 'external model';
    final info = GemmaModelInfo.defaultModel;
    final source = File(
      p.join(cacheDir.path, 'Downloads', info.downloadFileName),
    );
    source.parent.createSync(recursive: true);
    source.writeAsStringSync(modelBytes);

    await repository.importModelFromFile(info: info, sourcePath: source.path);

    final destination = File(await repository.modelFilePath(info));
    expect(source.existsSync(), isTrue);
    expect(destination.readAsStringSync(), modelBytes);
    expect(File('${destination.path}.importing').existsSync(), isFalse);
    expect(File('${destination.path}.backup').existsSync(), isFalse);
  });
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.cachePath);

  final String cachePath;

  @override
  Future<String?> getApplicationCachePath() async => cachePath;
}
