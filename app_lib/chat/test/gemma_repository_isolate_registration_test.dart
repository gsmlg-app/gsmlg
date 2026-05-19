import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'llama worker isolate initializes Flutter plugins before resolving library',
    () async {
      final source = await File(
        'lib/src/repositories/gemma_repository.dart',
      ).readAsString();

      final entrypointIndex = source.indexOf(
        'static void _llamaIsolateEntryPoint(_LlamaIsolateParams params) async',
      );
      expect(entrypointIndex, isNonNegative);

      final registrationIndex = source.indexOf(
        'DartPluginRegistrant.ensureInitialized();',
        entrypointIndex,
      );
      final resolveIndex = source.indexOf(
        'LibLlamaCppPlatform.instance',
        entrypointIndex,
      );

      expect(
        registrationIndex,
        isNonNegative,
        reason: 'The worker isolate must register Flutter plugins.',
      );
      expect(resolveIndex, isNonNegative);
      expect(registrationIndex, lessThan(resolveIndex));
    },
  );
}
