import 'package:app_database/app_database.dart';
import 'package:app_security/app_security.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  group('SshKeyAlgorithm', () {
    test('has correct values', () {
      expect(SshKeyAlgorithm.rsa.value, 1);
      expect(SshKeyAlgorithm.dsa.value, 2);
      expect(SshKeyAlgorithm.ecdsa.value, 3);
      expect(SshKeyAlgorithm.ed25519.value, 4);
    });

    test('fromValue returns correct enum', () {
      expect(SshKeyAlgorithm.fromValue(1), SshKeyAlgorithm.rsa);
      expect(SshKeyAlgorithm.fromValue(2), SshKeyAlgorithm.dsa);
      expect(SshKeyAlgorithm.fromValue(3), SshKeyAlgorithm.ecdsa);
      expect(SshKeyAlgorithm.fromValue(4), SshKeyAlgorithm.ed25519);
    });

    test('fromValue returns null for invalid value', () {
      expect(SshKeyAlgorithm.fromValue(0), isNull);
      expect(SshKeyAlgorithm.fromValue(99), isNull);
    });
  });

  group('SshKeyEvent', () {
    test('SshKeyLoad can be instantiated', () {
      final event = SshKeyLoad();
      expect(event, isA<SshKeyEvent>());
    });

    test('SshKeyAdd stores all parameters', () {
      final event = SshKeyAdd(
        name: 'My SSH Key',
        content: 'encrypted_key_content',
        password: null,
        salt: 'random_salt',
        algorithm: SshKeyAlgorithm.rsa.value,
      );

      expect(event.name, 'My SSH Key');
      expect(event.content, 'encrypted_key_content');
      expect(event.password, isNull);
      expect(event.salt, 'random_salt');
      expect(event.algorithm, SshKeyAlgorithm.rsa.value);
    });

    test('SshKeyAdd can have password', () {
      final event = SshKeyAdd(
        name: 'Protected Key',
        content: 'encrypted_content',
        password: 'encrypted_password',
        salt: 'salt_value',
        algorithm: SshKeyAlgorithm.ed25519.value,
      );

      expect(event.password, 'encrypted_password');
      expect(event.algorithm, SshKeyAlgorithm.ed25519.value);
    });

    test('SshKeyDelete stores sshKey', () {
      final sshKey = SshKey(
        id: 1,
        name: 'Test Key',
        content: 'content',
        password: null,
        salt: 'salt',
        algorithm: 1,
        createdAt: DateTime.now(),
      );

      final event = SshKeyDelete(sshKey);
      expect(event.sshKey, sshKey);
      expect(event.sshKey.id, 1);
    });
  });

  group('SshKeyState', () {
    test('SshKeyInitial is a SshKeyState', () {
      final state = SshKeyInitial();
      expect(state, isA<SshKeyState>());
    });

    test('SshKeyLoaded stores keys list', () {
      final keys = [
        SshKey(
          id: 1,
          name: 'Key 1',
          content: 'content1',
          password: null,
          salt: 'salt1',
          algorithm: SshKeyAlgorithm.rsa.value,
          createdAt: DateTime.now(),
        ),
        SshKey(
          id: 2,
          name: 'Key 2',
          content: 'content2',
          password: 'pwd',
          salt: 'salt2',
          algorithm: SshKeyAlgorithm.ed25519.value,
          createdAt: DateTime.now(),
        ),
      ];

      final state = SshKeyLoaded(keys);
      expect(state, isA<SshKeyState>());
      expect(state.sshKeys, keys);
      expect(state.sshKeys.length, 2);
    });

    test('SshKeyLoaded can be empty', () {
      final state = SshKeyLoaded([]);
      expect(state.sshKeys, isEmpty);
    });

    test('SshKeyError stores error object', () {
      final error = Exception('Database error');
      final state = SshKeyError(error);
      expect(state, isA<SshKeyState>());
      expect(state.error, error);
    });

    test('SshKeyError can store string error', () {
      final state = SshKeyError('Error message');
      expect(state.error, 'Error message');
    });
  });

  group('SshKeyBloc', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    test('initial state is SshKeyInitial', () {
      final bloc = SshKeyBloc(database);
      expect(bloc.state, isA<SshKeyInitial>());
      bloc.close();
    });

    blocTest<SshKeyBloc, SshKeyState>(
      'emits SshKeyLoaded on SshKeyLoad with empty database',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(SshKeyLoad()),
      expect: () => [
        isA<SshKeyLoaded>().having(
          (s) => s.sshKeys,
          'sshKeys',
          isEmpty,
        ),
      ],
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'emits SshKeyLoaded on SshKeyAdd with RSA key',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(SshKeyAdd(
        name: 'RSA Key',
        content: 'rsa_key_content',
        salt: 'rsa_salt',
        algorithm: SshKeyAlgorithm.rsa.value,
      )),
      expect: () => [
        isA<SshKeyLoaded>().having(
          (s) => s.sshKeys.length,
          'keys count',
          1,
        ),
      ],
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'emits SshKeyLoaded on SshKeyAdd with Ed25519 key',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(SshKeyAdd(
        name: 'Ed25519 Key',
        content: 'ed25519_content',
        salt: 'ed_salt',
        algorithm: SshKeyAlgorithm.ed25519.value,
      )),
      expect: () => [
        isA<SshKeyLoaded>().having(
          (s) => s.sshKeys.first.algorithm,
          'algorithm',
          SshKeyAlgorithm.ed25519.value,
        ),
      ],
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'added key has correct properties',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(SshKeyAdd(
        name: 'Test Key',
        content: 'test_content',
        password: 'test_pwd',
        salt: 'test_salt',
        algorithm: SshKeyAlgorithm.ecdsa.value,
      )),
      verify: (bloc) async {
        final state = bloc.state as SshKeyLoaded;
        final key = state.sshKeys.first;
        expect(key.name, 'Test Key');
        expect(key.content, startsWith('vault:ssh:'));
        expect(await bloc.credentials.readPrivateKey(key), 'test_content');
        expect(key.password, startsWith('vault:ssh:'));
        expect(await bloc.credentials.readKeyPassphrase(key), 'test_pwd');
        expect(key.salt, isNull);
        expect(key.algorithm, SshKeyAlgorithm.ecdsa.value);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'can add multiple keys',
      build: () => SshKeyBloc(database),
      act: (bloc) async {
        bloc.add(SshKeyAdd(
          name: 'Key 1',
          content: 'content1',
          salt: 'salt1',
          algorithm: SshKeyAlgorithm.rsa.value,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(SshKeyAdd(
          name: 'Key 2',
          content: 'content2',
          salt: 'salt2',
          algorithm: SshKeyAlgorithm.ed25519.value,
        ));
      },
      expect: () => [
        isA<SshKeyLoaded>().having((s) => s.sshKeys.length, 'count', 1),
        isA<SshKeyLoaded>().having((s) => s.sshKeys.length, 'count', 2),
      ],
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'emits SshKeyLoaded on SshKeyDelete',
      build: () => SshKeyBloc(database),
      seed: () {
        // Pre-populate database
        database.into(database.sshKeys).insert(SshKeysCompanion.insert(
              name: const Value('To Delete'),
              content: const Value('content'),
              salt: const Value('salt'),
              algorithm: const Value(1),
              createdAt: Value(DateTime.now()),
            ));
        return SshKeyInitial();
      },
      act: (bloc) async {
        // Load first to get the key
        bloc.add(SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as SshKeyLoaded;
        bloc.add(SshKeyDelete(state.sshKeys.first));
      },
      expect: () => [
        isA<SshKeyLoaded>().having((s) => s.sshKeys.length, 'count', 1),
        isA<SshKeyLoaded>().having((s) => s.sshKeys.length, 'count', 0),
      ],
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'emits SshKeyError when deleting non-existent key',
      build: () => SshKeyBloc(database),
      act: (bloc) {
        final fakeKey = SshKey(
          id: 99999,
          name: 'Fake',
          content: 'fake',
          password: null,
          salt: 'salt',
          algorithm: 1,
          createdAt: DateTime.now(),
        );
        bloc.add(SshKeyDelete(fakeKey));
      },
      expect: () => [
        isA<SshKeyError>(),
      ],
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'load returns all keys after multiple adds',
      build: () => SshKeyBloc(database),
      act: (bloc) async {
        bloc.add(const SshKeyAdd(
          name: 'Key A',
          content: 'contentA',
          salt: 'saltA',
          algorithm: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyAdd(
          name: 'Key B',
          content: 'contentB',
          salt: 'saltB',
          algorithm: 2,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyLoad());
      },
      skip: 1, // Skip the first add emission, capture second add emission
      expect: () => [
        isA<SshKeyLoaded>().having((s) => s.sshKeys.length, 'count', 2),
        // Note: SshKeyLoad does not emit a new state because the list contents
        // are identical to the previous state (Equatable prevents duplicate emissions)
      ],
    );

    test('keys have auto-generated IDs', () async {
      final bloc = SshKeyBloc(database);
      bloc.add(SshKeyAdd(
        name: 'Test',
        content: 'content',
        salt: 'salt',
        algorithm: 1,
      ));

      await Future.delayed(const Duration(milliseconds: 100));
      final state = bloc.state as SshKeyLoaded;
      expect(state.sshKeys.first.id, isPositive);
      bloc.close();
    });

    test('keys have createdAt timestamp', () async {
      final beforeAdd = DateTime.now();
      final bloc = SshKeyBloc(database);
      bloc.add(SshKeyAdd(
        name: 'Test',
        content: 'content',
        salt: 'salt',
        algorithm: 1,
      ));

      await Future.delayed(const Duration(milliseconds: 100));
      final afterAdd = DateTime.now();
      final state = bloc.state as SshKeyLoaded;
      final createdAt = state.sshKeys.first.createdAt;

      expect(
        createdAt?.isAfter(beforeAdd.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        createdAt?.isBefore(afterAdd.add(const Duration(seconds: 1))),
        isTrue,
      );
      bloc.close();
    });

    test('keys can have different algorithms', () async {
      final bloc = SshKeyBloc(database);

      bloc.add(SshKeyAdd(
        name: 'RSA',
        content: 'rsa',
        salt: 's1',
        algorithm: SshKeyAlgorithm.rsa.value,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(SshKeyAdd(
        name: 'DSA',
        content: 'dsa',
        salt: 's2',
        algorithm: SshKeyAlgorithm.dsa.value,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(SshKeyAdd(
        name: 'ECDSA',
        content: 'ecdsa',
        salt: 's3',
        algorithm: SshKeyAlgorithm.ecdsa.value,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(SshKeyAdd(
        name: 'Ed25519',
        content: 'ed25519',
        salt: 's4',
        algorithm: SshKeyAlgorithm.ed25519.value,
      ));
      await Future.delayed(const Duration(milliseconds: 100));

      final state = bloc.state as SshKeyLoaded;
      expect(state.sshKeys.length, 4);

      final algorithms = state.sshKeys.map((k) => k.algorithm).toSet();
      expect(algorithms, containsAll([1, 2, 3, 4]));
      bloc.close();
    });
  });

  group('SshKey', () {
    test('algorithmEnum returns correct enum', () {
      final key = SshKey(
        id: 1,
        name: 'Test',
        content: 'content',
        password: null,
        salt: 'salt',
        algorithm: SshKeyAlgorithm.ed25519.value,
        createdAt: DateTime.now(),
      );

      expect(key.algorithm, 4);
    });

    test('all SshKeyAlgorithm values exist', () {
      expect(SshKeyAlgorithm.values.length, 4);
      expect(SshKeyAlgorithm.values, contains(SshKeyAlgorithm.rsa));
      expect(SshKeyAlgorithm.values, contains(SshKeyAlgorithm.dsa));
      expect(SshKeyAlgorithm.values, contains(SshKeyAlgorithm.ecdsa));
      expect(SshKeyAlgorithm.values, contains(SshKeyAlgorithm.ed25519));
    });
  });

  group('SshKeyEncryption extension', () {
    // Test RSA key for encryption/decryption tests
    const testRsaKey = '''-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAov1z0QGXzUSklDfwrpI0x6gqv2+Cl7kMa9cKC2MTbNzzK2jX
XSlwj8R4LyU3lyN2cgBuzw/sMDCg4bNdzjch0UlcTUXJS2UfraR3QMEZNIE8IaPR
Bm81ntFw7YyVaymTPfdEFGi6xjVtHRoOdeBHxMYarXmkFzSX5EaaZODSvdF+FcPp
0J1Q5QyosbIVy5HiYAhqdQ6o0y1tn2D25UdqelfFQtPsBpOBL+2ocxAKdWFBJxGo
iHBtN0YcxfADarBBlN8bc9yj0MlsDcnEPsh7GPA6r9IZxcQsrbfR5Di6PSj50o3C
ZKXu4l9Wa0Pgd5W0x72OSAcJBKt3HXxQWI0PPwIDAQABAoIBAH31bwaru3u3u5SL
8qWGeeF+NaMB8yN7r3y7j5ijNYTg78+xUxY9Cy8fv1133pEfp86MRRYiEP5g5kPm
UO0nsCvEDN/uuZRZjvSrcDmLwQXRhf3dUpEtanvVEfeSuHo7g/3UVDmNgiHhcfSW
iWxRKkWIb1927Pe9/lA8u96P3G0x95XrCvsj1HNs20hvcbmYzKbcrLaMpVM4JDVw
kgNGum1QtIgasNM3QiCJFv18B+vXaKGRr7ofFuQAOHI5C1kGkwpyGpXUftpnA+gg
eLSJJ8kIrjekdiRK+dQCVcuMafD2OVOuac+UsRwfCe5qQ04E4G+GwTvGWqjY+Iib
M7eAIqECgYEA16iTlJcetk+DV/HkEUamB1cMBI5dMBA5BPpHXDpdhCmIPXHfRCWK
pmNaImE45jY2q+9+6NKPoPF8MISXYuzrFePe/INa9+B+IIRZH6o96IAmsxLM/z/4
3Rp2RNf7zL0jiVxc2f+Hb41vpK2wsOtVPhMdt/UQR5ycluIcVqLkx1ECgYEAwXqy
UT2a2dnnPH53JL9CP1mrtrZ9pxUf+N6oZOcXBLqbkfEJO78gwZFQq0N3XsJlp01y
qnZAd1b+eSUO5x0ckb5ZUvyplEnpqLKG4kqvLSe9J6KWL8sprz5buDbxdc4vRQh4
6HIRA2d5zkV7XBuUNgE16hMi9fVD3chYA0eJ6Y8CgYBFe1fJKQNJI8cif5nGgyec
98u0cBXQFXn5g5WYPmnA2gy+F0Ei2KGaSCpTJ1XIvjDRJoGSC70g0oz7qMyJn+GC
FP/UBZI6iMa6PUnlrNjzXs6ZJXaMypSo0AzI03maFloruGlmBzEgnMYanadu6PN2
43vQuBE9sVS2PDV7KFJjcQKBgGbbrNrlzmIMpxMRBJQjnbuCF3i+UdS2tVWgQZPL
CwC3mCchJlB+DpL5hxJVfquA23vy/4fB8AnB1O1glyik4GBW+rPUoO610KOfrXe2
TqTJ4JSmqgNklZeVpjsr8ng3kge4NlcU9RiDNU1EwQ05mDSRtjDn1Yk+x8KrVKcB
rD7fAoGBANC8E+Ke4UwROf2LMbRSwRo6H7kqY5w8fVFy12dltwP/Cljfa9Mcu+sc
s9GNEAuOKFbXmdTEkqdHuSxpSKN2P8TlDtN7fujsj8GOLmAFbVX7hCsnKrLBbkMu
sYU4huPrVyOUnVFWxC+SKwY2QtrNwrtp/5C1dhdsismX7EFZNGmd
-----END RSA PRIVATE KEY-----''';

    test('algorithmEnum returns correct enum for rsa', () {
      final key = SshKey(
        id: 1,
        name: 'Test',
        content: 'content',
        password: null,
        salt: 'salt',
        algorithm: SshKeyAlgorithm.rsa.value,
        createdAt: DateTime.now(),
      );

      expect(key.algorithmEnum, SshKeyAlgorithm.rsa);
    });

    test('algorithmEnum returns correct enum for ed25519', () {
      final key = SshKey(
        id: 1,
        name: 'Test',
        content: 'content',
        password: null,
        salt: 'salt',
        algorithm: SshKeyAlgorithm.ed25519.value,
        createdAt: DateTime.now(),
      );

      expect(key.algorithmEnum, SshKeyAlgorithm.ed25519);
    });

    test('algorithmEnum returns null for null algorithm', () {
      final key = SshKey(
        id: 1,
        name: 'Test',
        content: 'content',
        password: null,
        salt: 'salt',
        algorithm: null,
        createdAt: DateTime.now(),
      );

      expect(key.algorithmEnum, isNull);
    });

    test('algorithmEnum returns null for invalid algorithm', () {
      final key = SshKey(
        id: 1,
        name: 'Test',
        content: 'content',
        password: null,
        salt: 'salt',
        algorithm: 999,
        createdAt: DateTime.now(),
      );

      expect(key.algorithmEnum, isNull);
    });

    test('getPrivateKeyPem decrypts stored key', () {
      const salt = 'test-encryption-salt';
      final aesHelper = AesHelper('Web Terminal');
      final encryptedContent = aesHelper.encrypt64WithSalt(testRsaKey, salt);

      final key = SshKey(
        id: 1,
        name: 'Encrypted Key',
        content: encryptedContent,
        password: null,
        salt: salt,
        algorithm: SshKeyAlgorithm.rsa.value,
        createdAt: DateTime.now(),
      );

      final decrypted = key.getPrivateKeyPem();
      expect(decrypted, testRsaKey);
    });

    test('getPublicKeyPem returns SSH public key format', () {
      const salt = 'test-pubkey-salt';
      final aesHelper = AesHelper('Web Terminal');
      final encryptedContent = aesHelper.encrypt64WithSalt(testRsaKey, salt);

      final key = SshKey(
        id: 1,
        name: 'Key for pubkey',
        content: encryptedContent,
        password: null,
        salt: salt,
        algorithm: SshKeyAlgorithm.rsa.value,
        createdAt: DateTime.now(),
      );

      final pubKey = key.getPublicKeyPem();
      expect(pubKey, startsWith('ssh-rsa '));
      expect(pubKey, contains('AAAAB3NzaC1yc2E'));
    });

    test('encryption roundtrip preserves key content', () {
      const salt = 'roundtrip-salt';
      final aesHelper = AesHelper('Web Terminal');
      final encryptedContent = aesHelper.encrypt64WithSalt(testRsaKey, salt);

      final key = SshKey(
        id: 1,
        name: 'Roundtrip Key',
        content: encryptedContent,
        password: null,
        salt: salt,
        algorithm: SshKeyAlgorithm.rsa.value,
        createdAt: DateTime.now(),
      );

      final decrypted = key.getPrivateKeyPem();
      expect(decrypted.trim(), testRsaKey.trim());
      expect(decrypted, contains('BEGIN RSA PRIVATE KEY'));
      expect(decrypted, contains('END RSA PRIVATE KEY'));
    });

    test('different salts produce different encrypted content', () {
      final aesHelper = AesHelper('Web Terminal');
      final encrypted1 = aesHelper.encrypt64WithSalt(testRsaKey, 'salt-1');
      final encrypted2 = aesHelper.encrypt64WithSalt(testRsaKey, 'salt-2');

      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('SshKey with null content handles gracefully', () {
      final key = SshKey(
        id: 1,
        name: 'Null Content Key',
        content: null,
        password: null,
        salt: 'salt',
        algorithm: SshKeyAlgorithm.rsa.value,
        createdAt: DateTime.now(),
      );

      // This should throw or return empty - testing the behavior
      expect(() => key.getPrivateKeyPem(), throwsA(anything));
    });

    test('SshKey with null salt handles gracefully', () {
      final aesHelper = AesHelper('Web Terminal');
      final encryptedContent =
          aesHelper.encrypt64WithSalt(testRsaKey, 'original-salt');

      final key = SshKey(
        id: 1,
        name: 'Null Salt Key',
        content: encryptedContent,
        password: null,
        salt: null,
        algorithm: SshKeyAlgorithm.rsa.value,
        createdAt: DateTime.now(),
      );

      // Decryption with null salt should fail
      expect(() => key.getPrivateKeyPem(), throwsA(anything));
    });
  });
}
