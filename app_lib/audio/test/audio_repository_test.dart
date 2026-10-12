import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_secure_storage/vault_repository.dart';
import 'package:app_audio/audio.dart';

class FakeVaultRepository implements VaultRepository {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({required String key}) async => _storage[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<bool> containsKey({required String key}) async =>
      _storage.containsKey(key);

  @override
  Future<void> deleteAll() async => _storage.clear();

  @override
  Future<Map<String, String>> readAll() async => Map.from(_storage);
}

void main() {
  group('OpenAiAudioRepository', () {
    group('resolveToken', () {
      test('returns null when useDummyToken is true', () async {
        final vault = FakeVaultRepository();
        await vault.write(key: 'service_account_1', value: 'secret-token');

        final repo = OpenAiAudioRepository(vault: vault);
        const settings = AudioSettings(accountId: 1, useDummyToken: true);

        final token = await repo.resolveToken(settings);
        expect(token, isNull);
      });

      test('returns null when accountId is null', () async {
        final vault = FakeVaultRepository();
        final repo = OpenAiAudioRepository(vault: vault);
        const settings = AudioSettings(accountId: null, useDummyToken: false);

        final token = await repo.resolveToken(settings);
        expect(token, isNull);
      });

      test(
        'reads and trims token from VaultRepository when accountId is set',
        () async {
          final vault = FakeVaultRepository();
          await vault.write(
            key: 'service_account_42',
            value: '  secret-bearer-token  \n',
          );

          final repo = OpenAiAudioRepository(vault: vault);
          const settings = AudioSettings(accountId: 42, useDummyToken: false);

          final token = await repo.resolveToken(settings);
          expect(token, 'secret-bearer-token');
        },
      );

      test('returns null when vault is null or key does not exist', () async {
        final repoWithoutVault = OpenAiAudioRepository();
        const settings = AudioSettings(accountId: 99);
        expect(await repoWithoutVault.resolveToken(settings), isNull);

        final vault = FakeVaultRepository();
        final repoWithEmptyVault = OpenAiAudioRepository(vault: vault);
        expect(await repoWithEmptyVault.resolveToken(settings), isNull);
      });
    });

    group('synthesizeSpeech', () {
      test(
        'verifies HTTP POST payload, headers, and returns audio bytes on 200',
        () async {
          final vault = FakeVaultRepository();
          await vault.write(key: 'service_account_5', value: 'token-abc');

          final mockClient = MockClient((request) async {
            expect(request.method, 'POST');
            expect(
              request.url.toString(),
              'https://backplane.gsmlg.net/v1/audio/speech',
            );
            expect(
              request.headers['content-type'],
              contains('application/json'),
            );
            expect(request.headers['authorization'], 'Bearer token-abc');

            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['model'], 'minimax-audio/speech-2.8-turbo');
            expect(body['input'], 'Hello world');
            expect(body['voice'], 'alloy');
            expect(body['speed'], 1.0);
            expect(body['response_format'], 'mp3');

            return http.Response.bytes(Uint8List.fromList([1, 2, 3, 4]), 200);
          });

          final repo = OpenAiAudioRepository(
            vault: vault,
            httpClient: mockClient,
          );
          const settings = AudioSettings(
            baseUrl: 'https://backplane.gsmlg.net/v1///',
            accountId: 5,
          );

          final bytes = await repo.synthesizeSpeech(settings, 'Hello world');
          expect(bytes, Uint8List.fromList([1, 2, 3, 4]));
        },
      );

      test(
        'supports parameter overrides and omits Authorization when token is null',
        () async {
          final mockClient = MockClient((request) async {
            expect(request.headers.containsKey('authorization'), isFalse);

            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['model'], 'tts-1-hd');
            expect(body['input'], 'Custom text');
            expect(body['voice'], 'echo');
            expect(body['speed'], 1.5);
            expect(body['response_format'], 'wav');

            return http.Response.bytes(Uint8List.fromList([9, 8, 7]), 200);
          });

          final repo = OpenAiAudioRepository(httpClient: mockClient);
          const settings = AudioSettings(useDummyToken: true);

          final bytes = await repo.synthesizeSpeech(
            settings,
            'Custom text',
            model: 'tts-1-hd',
            voice: 'echo',
            speed: 1.5,
            format: 'wav',
          );
          expect(bytes, Uint8List.fromList([9, 8, 7]));
        },
      );

      test('throws HttpException on 4xx/5xx responses', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Unauthorized', 401);
        });

        final repo = OpenAiAudioRepository(httpClient: mockClient);
        const settings = AudioSettings(useDummyToken: true);

        expect(
          () => repo.synthesizeSpeech(settings, 'Hello'),
          throwsA(
            isA<HttpException>().having(
              (e) => e.message,
              'message',
              contains('401'),
            ),
          ),
        );
      });
    });

    group('transcribeAudio', () {
      test(
        'verifies multipart POST fields, file data, and parses text on 200',
        () async {
          final vault = FakeVaultRepository();
          await vault.write(key: 'service_account_7', value: 'token-xyz');

          final mockClient = MockClient((request) async {
            expect(request.method, 'POST');
            expect(
              request.url.toString(),
              'https://backplane.gsmlg.net/v1/audio/transcriptions',
            );
            expect(request.headers['authorization'], 'Bearer token-xyz');
            expect(
              request.headers['content-type'],
              contains('multipart/form-data'),
            );

            final body = request.body;
            expect(body, contains('name="model"'));
            expect(body, contains('minimax-audio/asr-1.0'));
            expect(body, contains('name="response_format"'));
            expect(body, contains('json'));
            expect(body, contains('name="language"'));
            expect(body, contains('zh'));
            expect(body, contains('name="file"'));
            expect(body, contains('filename="sample.wav"'));

            return http.Response(
              jsonEncode({'text': 'Hello world transcript'}),
              200,
            );
          });

          final repo = OpenAiAudioRepository(
            vault: vault,
            httpClient: mockClient,
          );
          const settings = AudioSettings(
            baseUrl: 'https://backplane.gsmlg.net/v1/',
            accountId: 7,
            asrLanguage: 'zh',
          );

          final result = await repo.transcribeAudio(
            settings,
            bytes: [10, 20, 30],
            filename: 'sample.wav',
          );
          expect(result, 'Hello world transcript');
        },
      );

      test(
        'supports parameter overrides and omits language when not set',
        () async {
          final mockClient = MockClient((request) async {
            final body = request.body;
            expect(body, contains('name="model"'));
            expect(body, contains('whisper-large'));
            expect(body, contains('name="language"'));
            expect(body, contains('fr'));

            return http.Response(jsonEncode({'text': 'Bonjour'}), 200);
          });

          final repo = OpenAiAudioRepository(httpClient: mockClient);
          const settings = AudioSettings(useDummyToken: true);

          final result = await repo.transcribeAudio(
            settings,
            bytes: [1, 2, 3],
            model: 'whisper-large',
            language: 'fr',
          );
          expect(result, 'Bonjour');
        },
      );

      test('throws HttpException on error response', () async {
        final mockClient = MockClient((request) async {
          return http.Response('Bad Request', 400);
        });

        final repo = OpenAiAudioRepository(httpClient: mockClient);
        const settings = AudioSettings(useDummyToken: true);

        expect(
          () => repo.transcribeAudio(settings, bytes: [1, 2, 3]),
          throwsA(
            isA<HttpException>().having(
              (e) => e.message,
              'message',
              contains('400'),
            ),
          ),
        );
      });

      test(
        'throws ArgumentError when neither filePath nor bytes is provided',
        () async {
          final repo = OpenAiAudioRepository();
          const settings = AudioSettings(useDummyToken: true);

          expect(
            () => repo.transcribeAudio(settings),
            throwsA(isA<ArgumentError>()),
          );
        },
      );

      test('transcribes audio from filePath when provided', () async {
        final tempDir = await Directory.systemTemp.createTemp('audio_test_');
        addTearDown(() => tempDir.deleteSync(recursive: true));
        final tempFile = File('${tempDir.path}/test_recording.wav');
        await tempFile.writeAsBytes([5, 6, 7, 8]);

        final mockClient = MockClient((request) async {
          expect(request.body, contains('name="file"'));
          expect(request.body, contains('filename="test_recording.wav"'));
          return http.Response(jsonEncode({'text': 'File transcript'}), 200);
        });

        final repo = OpenAiAudioRepository(httpClient: mockClient);
        const settings = AudioSettings(useDummyToken: true);

        final result = await repo.transcribeAudio(
          settings,
          filePath: tempFile.path,
        );
        expect(result, 'File transcript');
      });

      test(
        'determines contentType from filename extension for bytes upload',
        () async {
          final expectedMimes = {
            'test.mp3': 'audio/mpeg',
            'test.m4a': 'audio/mp4',
            'test.ogg': 'audio/ogg',
            'test.webm': 'audio/webm',
            'test.wav': 'audio/wav',
            'test.flac': 'audio/flac',
            'test.unknown': 'audio/wav',
          };

          for (final entry in expectedMimes.entries) {
            final mockClient = MockClient((request) async {
              expect(
                request.body.toLowerCase(),
                contains('content-type: ${entry.value}'),
                reason: 'File ${entry.key} should produce MIME ${entry.value}',
              );
              return http.Response(jsonEncode({'text': 'ok'}), 200);
            });

            final repo = OpenAiAudioRepository(httpClient: mockClient);
            const settings = AudioSettings(useDummyToken: true);

            final result = await repo.transcribeAudio(
              settings,
              bytes: [1, 2, 3],
              filename: entry.key,
            );
            expect(result, 'ok');
          }
        },
      );
    });
  });
}
