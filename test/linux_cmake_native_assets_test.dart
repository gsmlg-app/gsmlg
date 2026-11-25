import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _extractNativeAssetsSection(String cmakeLists) {
  final lines = cmakeLists.split('\n');
  final start = lines.indexWhere(
    (line) => line.contains('set(NATIVE_ASSETS_DIR'),
  );
  if (start == -1) {
    throw StateError(
      'Could not find NATIVE_ASSETS_DIR in linux/CMakeLists.txt',
    );
  }

  final end = lines.indexWhere(
    (line) => line.contains('set(FLUTTER_ASSET_DIR_NAME'),
    start,
  );
  if (end == -1) {
    throw StateError(
      'Could not find FLUTTER_ASSET_DIR_NAME after NATIVE_ASSETS_DIR',
    );
  }

  return lines.sublist(start, end).join('\n');
}

String? _findCmakeExecutable() {
  try {
    final probe = Process.runSync('cmake', ['--version']);
    if (probe.exitCode == 0) {
      return 'cmake';
    }
  } on ProcessException {
    return null;
  }
  return null;
}

void main() {
  final cmakeFile = File('linux/CMakeLists.txt');

  test(
    'linux/CMakeLists.txt registers native_assets install rule unconditionally with OPTIONAL',
    () {
      expect(cmakeFile.existsSync(), isTrue);
      final section = _extractNativeAssetsSection(cmakeFile.readAsStringSync());

      expect(
        section,
        isNot(contains('if(EXISTS')),
        reason:
            'Checking native_assets existence at configure time skips the install '
            'rule on a clean first build before build hooks run.',
      );
      expect(section, contains('install(DIRECTORY "\${NATIVE_ASSETS_DIR}"'));
      expect(section, contains('DESTINATION "\${INSTALL_BUNDLE_LIB_DIR}"'));
      expect(section, contains('OPTIONAL'));
    },
  );

  test(
    'clean CMake configure + post-configure native_assets generation bundles libraries',
    () async {
      final cmake = _findCmakeExecutable();
      if (cmake == null) {
        markTestSkipped('cmake is not available on PATH');
        return;
      }

      final section = _extractNativeAssetsSection(cmakeFile.readAsStringSync());
      final tempDir = await Directory.systemTemp.createTemp(
        'linux-cmake-native-assets-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final projectDir = Directory('${tempDir.path}/project')..createSync();
      final projectBuildDir = '${projectDir.path}/build/';
      final srcDir = Directory('${tempDir.path}/src')..createSync();
      final outDir = Directory('${tempDir.path}/out');
      final bundleDir = Directory('${outDir.path}/bundle');

      File('${srcDir.path}/CMakeLists.txt').writeAsStringSync('''
cmake_minimum_required(VERSION 3.13)
project(native_assets_install_test LANGUAGES NONE)
set(PROJECT_BUILD_DIR "$projectBuildDir")
set(BUILD_BUNDLE_DIR "\${PROJECT_BINARY_DIR}/bundle")
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "\${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()
set(INSTALL_BUNDLE_LIB_DIR "\${CMAKE_INSTALL_PREFIX}/lib")
$section
''');

      // Clean first build: build/native_assets/linux/ does not exist during configure.
      final configure = await Process.run(cmake, [
        '-S',
        srcDir.path,
        '-B',
        outDir.path,
      ]);
      expect(
        configure.exitCode,
        0,
        reason:
            'cmake configure failed:\n${configure.stdout}\n${configure.stderr}',
      );

      // Simulate hook/build.dart generating native assets during the build phase.
      final nativeAssetsDir = Directory('${projectBuildDir}native_assets/linux')
        ..createSync(recursive: true);
      File(
        '${nativeAssetsDir.path}/libcnativeapi.so',
      ).writeAsStringSync('fake-cnativeapi');
      File(
        '${nativeAssetsDir.path}/libsqlite3.so',
      ).writeAsStringSync('fake-sqlite3');

      final installWithAssets = await Process.run(cmake, [
        '--install',
        outDir.path,
        '--component',
        'Runtime',
      ]);
      expect(
        installWithAssets.exitCode,
        0,
        reason:
            'cmake install failed:\n${installWithAssets.stdout}\n${installWithAssets.stderr}',
      );

      expect(
        File('${bundleDir.path}/lib/libcnativeapi.so').readAsStringSync(),
        'fake-cnativeapi',
        reason: 'libcnativeapi.so must be copied into bundle/lib/',
      );
      expect(
        File('${bundleDir.path}/lib/libsqlite3.so').readAsStringSync(),
        'fake-sqlite3',
        reason: 'libsqlite3.so must be copied into bundle/lib/',
      );
      expect(
        Directory('${bundleDir.path}/lib/linux').existsSync(),
        isFalse,
        reason:
            'Native assets must be installed directly into bundle/lib/, not bundle/lib/linux/',
      );

      // When no native assets directory exists at install time, OPTIONAL keeps install succeeding.
      await nativeAssetsDir.delete(recursive: true);
      await bundleDir.delete(recursive: true);
      final installWithoutAssets = await Process.run(cmake, [
        '--install',
        outDir.path,
        '--component',
        'Runtime',
      ]);
      expect(
        installWithoutAssets.exitCode,
        0,
        reason:
            'OPTIONAL install must succeed when native_assets/linux is absent:\n'
            '${installWithoutAssets.stdout}\n${installWithoutAssets.stderr}',
      );
    },
  );
}
