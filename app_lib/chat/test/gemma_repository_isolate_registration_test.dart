import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'local llama server resolves the platform library before opening',
    () async {
      final source = await File(
        'lib/src/repositories/gemma_repository.dart',
      ).readAsString();

      final startIndex = source.indexOf(
        'static Future<LocalLlamaServerSession> start',
      );
      expect(startIndex, isNonNegative);

      final resolveIndex = source.indexOf(
        'LibLlamaCppPlatform.instance',
        startIndex,
      );
      final openIndex = source.indexOf('LlamaHttpServer.open', startIndex);

      expect(resolveIndex, isNonNegative);
      expect(openIndex, isNonNegative);
      expect(resolveIndex, lessThan(openIndex));
    },
  );
}
