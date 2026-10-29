import 'package:app_database/app_database.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  group('SshIdentityType', () {
    test('has correct values', () {
      expect(SshIdentityType.password.value, 1);
      expect(SshIdentityType.key.value, 2);
    });

    test('fromValue returns correct enum', () {
      expect(SshIdentityType.fromValue(1), SshIdentityType.password);
      expect(SshIdentityType.fromValue(2), SshIdentityType.key);
    });

    test('fromValue returns null for invalid value', () {
      expect(SshIdentityType.fromValue(0), isNull);
      expect(SshIdentityType.fromValue(99), isNull);
    });
  });

  group('SshHostEvent', () {
    test('SshHostLoad can be instantiated', () {
      final event = SshHostLoad();
      expect(event, isA<SshHostEvent>());
    });

    test('SshHostAdd stores all parameters', () {
      final event = SshHostAdd(
        host: 'My Server',
        hostname: 'example.com',
        port: 22,
        username: 'admin',
        password: 'encrypted_password',
        salt: 'random_salt',
        identityType: SshIdentityType.password.value,
        identityKeyId: null,
      );

      expect(event.host, 'My Server');
      expect(event.hostname, 'example.com');
      expect(event.port, 22);
      expect(event.username, 'admin');
      expect(event.password, 'encrypted_password');
      expect(event.salt, 'random_salt');
      expect(event.identityType, SshIdentityType.password.value);
      expect(event.identityKeyId, isNull);
    });

    test('SshHostAdd can have key-based identity', () {
      final event = SshHostAdd(
        host: 'Key Auth Server',
        hostname: 'keyserver.com',
        port: 2222,
        username: 'developer',
        password: null,
        salt: null,
        identityType: SshIdentityType.key.value,
        identityKeyId: 42,
      );

      expect(event.identityType, SshIdentityType.key.value);
      expect(event.identityKeyId, 42);
      expect(event.password, isNull);
    });

    test('SshHostDelete stores sshHost', () {
      final sshHost = SshHost(
        id: 1,
        host: 'Test',
        hostname: 'test.com',
        port: 22,
        username: 'user',
        password: null,
        salt: null,
        identityType: 1,
        identityKeyId: null,
        createdAt: DateTime.now(),
      );

      final event = SshHostDelete(sshHost);
      expect(event.sshHost, sshHost);
      expect(event.sshHost.id, 1);
    });
  });

  group('SshHostState', () {
    test('SshHostInitial is a SshHostState', () {
      final state = SshHostInitial();
      expect(state, isA<SshHostState>());
    });

    test('SshHostLoaded stores hosts list', () {
      final hosts = [
        SshHost(
          id: 1,
          host: 'Server 1',
          hostname: 'server1.com',
          port: 22,
          username: 'user1',
          password: null,
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        ),
        SshHost(
          id: 2,
          host: 'Server 2',
          hostname: 'server2.com',
          port: 2222,
          username: 'user2',
          password: null,
          salt: null,
          identityType: 2,
          identityKeyId: 1,
          createdAt: DateTime.now(),
        ),
      ];

      final state = SshHostLoaded(hosts);
      expect(state, isA<SshHostState>());
      expect(state.sshHosts, hosts);
      expect(state.sshHosts.length, 2);
    });

    test('SshHostLoaded can be empty', () {
      final state = SshHostLoaded([]);
      expect(state.sshHosts, isEmpty);
    });

    test('SshHostError stores error object', () {
      final error = Exception('Database connection failed');
      final state = SshHostError(error);
      expect(state, isA<SshHostState>());
      expect(state.error, error);
    });

    test('SshHostError can store string error', () {
      final state = SshHostError('Simple error message');
      expect(state.error, 'Simple error message');
    });
  });

  group('SshHostBloc', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    test('initial state is SshHostInitial', () {
      final bloc = SshHostBloc(database);
      expect(bloc.state, isA<SshHostInitial>());
      bloc.close();
    });

    blocTest<SshHostBloc, SshHostState>(
      'emits SshHostLoaded on SshHostLoad with empty database',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(SshHostLoad()),
      expect: () => [
        isA<SshHostLoaded>().having(
          (s) => s.sshHosts,
          'sshHosts',
          isEmpty,
        ),
      ],
    );

    blocTest<SshHostBloc, SshHostState>(
      'emits SshHostLoaded on SshHostAdd with password auth',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(SshHostAdd(
        host: 'Test Server',
        hostname: 'test.example.com',
        port: 22,
        username: 'testuser',
        password: 'encrypted_pwd',
        salt: 'test_salt',
        identityType: SshIdentityType.password.value,
      )),
      expect: () => [
        isA<SshHostLoaded>().having(
          (s) => s.sshHosts.length,
          'hosts count',
          1,
        ),
      ],
    );

    blocTest<SshHostBloc, SshHostState>(
      'emits SshHostLoaded on SshHostAdd with key auth',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(SshHostAdd(
        host: 'Key Server',
        hostname: 'keyauth.example.com',
        port: 2222,
        username: 'keyuser',
        identityType: SshIdentityType.key.value,
        identityKeyId: 1,
      )),
      expect: () => [
        isA<SshHostLoaded>().having(
          (s) => s.sshHosts.first.identityType,
          'identityType',
          SshIdentityType.key.value,
        ),
      ],
    );

    blocTest<SshHostBloc, SshHostState>(
      'added host has correct properties',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(SshHostAdd(
        host: 'My Host',
        hostname: 'myhost.com',
        port: 443,
        username: 'admin',
        password: 'secret',
        salt: 'pepper',
        identityType: 1,
      )),
      verify: (bloc) async {
        final state = bloc.state as SshHostLoaded;
        final host = state.sshHosts.first;
        expect(host.host, 'My Host');
        expect(host.hostname, 'myhost.com');
        expect(host.port, 443);
        expect(host.username, 'admin');
        expect(host.password, startsWith('vault:ssh:'));
        expect(await bloc.credentials.readHostPassword(host), 'secret');
        expect(host.salt, isNull);
        expect(host.identityType, 1);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'can add multiple hosts',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        bloc.add(SshHostAdd(
          host: 'Server 1',
          hostname: 'server1.com',
          port: 22,
          username: 'user1',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(SshHostAdd(
          host: 'Server 2',
          hostname: 'server2.com',
          port: 22,
          username: 'user2',
          identityType: 1,
        ));
      },
      expect: () => [
        isA<SshHostLoaded>().having((s) => s.sshHosts.length, 'count', 1),
        isA<SshHostLoaded>().having((s) => s.sshHosts.length, 'count', 2),
      ],
    );

    blocTest<SshHostBloc, SshHostState>(
      'emits SshHostLoaded on SshHostDelete',
      build: () => SshHostBloc(database),
      seed: () {
        // Pre-populate database
        database.into(database.sshHosts).insert(SshHostsCompanion.insert(
              host: const Value('To Delete'),
              hostname: const Value('delete.com'),
              port: const Value(22),
              username: const Value('user'),
              identityType: const Value(1),
              createdAt: Value(DateTime.now()),
            ));
        return SshHostInitial();
      },
      act: (bloc) async {
        // Load first to get the host
        bloc.add(SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as SshHostLoaded;
        bloc.add(SshHostDelete(state.sshHosts.first));
      },
      expect: () => [
        isA<SshHostLoaded>().having((s) => s.sshHosts.length, 'count', 1),
        isA<SshHostLoaded>().having((s) => s.sshHosts.length, 'count', 0),
      ],
    );

    blocTest<SshHostBloc, SshHostState>(
      'emits SshHostError when deleting non-existent host',
      build: () => SshHostBloc(database),
      act: (bloc) {
        final fakeHost = SshHost(
          id: 99999,
          host: 'Fake',
          hostname: 'fake.com',
          port: 22,
          username: 'fake',
          password: null,
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );
        bloc.add(SshHostDelete(fakeHost));
      },
      expect: () => [
        isA<SshHostError>(),
      ],
    );

    blocTest<SshHostBloc, SshHostState>(
      'load returns all hosts after multiple adds',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        bloc.add(const SshHostAdd(
          host: 'Host 1',
          hostname: 'h1.com',
          port: 22,
          username: 'u1',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostAdd(
          host: 'Host 2',
          hostname: 'h2.com',
          port: 22,
          username: 'u2',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostLoad());
      },
      skip: 1, // Skip the first add emission, capture second add emission
      expect: () => [
        isA<SshHostLoaded>().having((s) => s.sshHosts.length, 'count', 2),
        // Note: SshHostLoad does not emit a new state because the list contents
        // are identical to the previous state (Equatable prevents duplicate emissions)
      ],
    );

    test('hosts have auto-generated IDs', () async {
      final bloc = SshHostBloc(database);
      bloc.add(SshHostAdd(
        host: 'Test',
        hostname: 'test.com',
        port: 22,
        username: 'user',
        identityType: 1,
      ));

      await Future.delayed(const Duration(milliseconds: 100));
      final state = bloc.state as SshHostLoaded;
      expect(state.sshHosts.first.id, isPositive);
      bloc.close();
    });

    test('hosts have createdAt timestamp', () async {
      final beforeAdd = DateTime.now();
      final bloc = SshHostBloc(database);
      bloc.add(SshHostAdd(
        host: 'Test',
        hostname: 'test.com',
        port: 22,
        username: 'user',
        identityType: 1,
      ));

      await Future.delayed(const Duration(milliseconds: 100));
      final afterAdd = DateTime.now();
      final state = bloc.state as SshHostLoaded;
      final createdAt = state.sshHosts.first.createdAt;

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
  });
}
