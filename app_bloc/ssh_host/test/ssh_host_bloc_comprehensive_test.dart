import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';

/// Comprehensive test suite for SshHostBloc covering:
/// - Event Equatable behavior
/// - State Equatable behavior and copyWith
/// - Database persistence patterns
/// - Complex scenarios (rapid updates, concurrent operations)
/// - Edge cases (special characters, boundaries, unicode)
/// - Load event edge cases
/// - State immutability
/// - Constants verification
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  group('SshHostEvent Equatable Tests', () {
    test('SshHostLoad events are equal', () {
      const event1 = SshHostLoad();
      const event2 = SshHostLoad();
      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('SshHostAdd events with same params are equal', () {
      const event1 = SshHostAdd(
        host: 'Server1',
        hostname: 'server1.com',
        port: 22,
        username: 'user1',
        password: 'pwd123',
        salt: 'salt123',
        identityType: 1,
        identityKeyId: null,
      );
      const event2 = SshHostAdd(
        host: 'Server1',
        hostname: 'server1.com',
        port: 22,
        username: 'user1',
        password: 'pwd123',
        salt: 'salt123',
        identityType: 1,
        identityKeyId: null,
      );
      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('SshHostAdd events with different params are not equal', () {
      const event1 = SshHostAdd(
        host: 'Server1',
        hostname: 'server1.com',
        port: 22,
        username: 'user1',
        identityType: 1,
      );
      const event2 = SshHostAdd(
        host: 'Server2',
        hostname: 'server2.com',
        port: 22,
        username: 'user1',
        identityType: 1,
      );
      expect(event1, isNot(equals(event2)));
    });

    test('SshHostAdd events with different identity types are not equal', () {
      const event1 = SshHostAdd(
        host: 'Server1',
        hostname: 'server1.com',
        port: 22,
        username: 'user1',
        identityType: 1, // password
      );
      const event2 = SshHostAdd(
        host: 'Server1',
        hostname: 'server1.com',
        port: 22,
        username: 'user1',
        identityType: 2, // key
        identityKeyId: 42,
      );
      expect(event1, isNot(equals(event2)));
    });

    test('SshHostDelete events with same host are equal', () {
      final host = SshHost(
        id: 1,
        host: 'TestHost',
        hostname: 'test.com',
        port: 22,
        username: 'user',
        password: null,
        salt: null,
        identityType: 1,
        identityKeyId: null,
        createdAt: DateTime.now(),
      );
      final event1 = SshHostDelete(host);
      final event2 = SshHostDelete(host);
      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('SshHostDelete events with different host IDs are not equal', () {
      final host1 = SshHost(
        id: 1,
        host: 'TestHost',
        hostname: 'test.com',
        port: 22,
        username: 'user',
        password: null,
        salt: null,
        identityType: 1,
        identityKeyId: null,
        createdAt: DateTime.now(),
      );
      final host2 = SshHost(
        id: 2,
        host: 'TestHost',
        hostname: 'test.com',
        port: 22,
        username: 'user',
        password: null,
        salt: null,
        identityType: 1,
        identityKeyId: null,
        createdAt: DateTime.now(),
      );
      final event1 = SshHostDelete(host1);
      final event2 = SshHostDelete(host2);
      expect(event1, isNot(equals(event2)));
    });
  });

  group('SshHostState Equatable Tests', () {
    test('SshHostInitial states are equal', () {
      const state1 = SshHostInitial();
      const state2 = SshHostInitial();
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('SshHostLoaded states with same hosts are equal', () {
      final hosts = [
        SshHost(
          id: 1,
          host: 'Server1',
          hostname: 'server1.com',
          port: 22,
          username: 'user1',
          password: null,
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        ),
      ];
      final state1 = SshHostLoaded(hosts);
      final state2 = SshHostLoaded(hosts);
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('SshHostLoaded states with different hosts are not equal', () {
      final hosts1 = [
        SshHost(
          id: 1,
          host: 'Server1',
          hostname: 'server1.com',
          port: 22,
          username: 'user1',
          password: null,
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        ),
      ];
      final hosts2 = [
        SshHost(
          id: 2,
          host: 'Server2',
          hostname: 'server2.com',
          port: 22,
          username: 'user2',
          password: null,
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        ),
      ];
      final state1 = SshHostLoaded(hosts1);
      final state2 = SshHostLoaded(hosts2);
      expect(state1, isNot(equals(state2)));
    });

    test('SshHostError states with same error are equal', () {
      const error = 'Database error';
      const state1 = SshHostError(error);
      const state2 = SshHostError(error);
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('SshHostError states with different errors are not equal', () {
      const state1 = SshHostError('Error 1');
      const state2 = SshHostError('Error 2');
      expect(state1, isNot(equals(state2)));
    });

    test('Empty SshHostLoaded states are equal', () {
      const state1 = SshHostLoaded([]);
      const state2 = SshHostLoaded([]);
      expect(state1, equals(state2));
    });
  });

  group('Database Persistence Tests', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    blocTest<SshHostBloc, SshHostState>(
      'SshHostAdd persists password auth host to database',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'PersistTest',
        hostname: 'persist.com',
        port: 2222,
        username: 'persistuser',
        password: 'encrypted',
        salt: 'salty',
        identityType: 1,
      )),
      verify: (_) async {
        final hosts = await database.select(database.sshHosts).get();
        expect(hosts.length, 1);
        expect(hosts.first.host, 'PersistTest');
        expect(hosts.first.hostname, 'persist.com');
        expect(hosts.first.port, 2222);
        expect(hosts.first.username, 'persistuser');
        expect(hosts.first.password, startsWith('vault:ssh:'));
        expect(
            await SshCredentialRepository(database)
                .readHostPassword(hosts.first),
            'encrypted');
        expect(hosts.first.salt, isNull);
        expect(hosts.first.identityType, 1);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'SshHostAdd persists key auth host to database',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'KeyHost',
        hostname: 'keyhost.com',
        port: 22,
        username: 'keyuser',
        identityType: 2,
        identityKeyId: 5,
      )),
      verify: (_) async {
        final hosts = await database.select(database.sshHosts).get();
        expect(hosts.length, 1);
        expect(hosts.first.identityType, 2);
        expect(hosts.first.identityKeyId, 5);
        expect(hosts.first.password, isNull);
        expect(hosts.first.salt, isNull);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'SshHostDelete removes host from database',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        // Add a host first
        bloc.add(const SshHostAdd(
          host: 'ToDelete',
          hostname: 'delete.com',
          port: 22,
          username: 'user',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 100));

        // Get the host and delete it
        final state = bloc.state as SshHostLoaded;
        bloc.add(SshHostDelete(state.sshHosts.first));
      },
      verify: (_) async {
        final hosts = await database.select(database.sshHosts).get();
        expect(hosts.length, 0);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'SshHostLoad reads all persisted hosts from database',
      setUp: () async {
        // Pre-populate database with 3 hosts
        await database.into(database.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('Host1'),
                hostname: const Value('h1.com'),
                port: const Value(22),
                username: const Value('u1'),
                identityType: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );
        await database.into(database.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('Host2'),
                hostname: const Value('h2.com'),
                port: const Value(2222),
                username: const Value('u2'),
                identityType: const Value(2),
                identityKeyId: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );
        await database.into(database.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('Host3'),
                hostname: const Value('h3.com'),
                port: const Value(443),
                username: const Value('u3'),
                identityType: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );
      },
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostLoad()),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.length, 3);
        expect(state.sshHosts[0].host, 'Host1');
        expect(state.sshHosts[1].host, 'Host2');
        expect(state.sshHosts[2].host, 'Host3');
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Multiple adds accumulate in database',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        bloc.add(const SshHostAdd(
          host: 'Host1',
          hostname: 'h1.com',
          port: 22,
          username: 'u1',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostAdd(
          host: 'Host2',
          hostname: 'h2.com',
          port: 22,
          username: 'u2',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostAdd(
          host: 'Host3',
          hostname: 'h3.com',
          port: 22,
          username: 'u3',
          identityType: 1,
        ));
      },
      verify: (_) async {
        final hosts = await database.select(database.sshHosts).get();
        expect(hosts.length, 3);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Database persists across BLoC instances',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'Persistent',
        hostname: 'persist.com',
        port: 22,
        username: 'user',
        identityType: 1,
      )),
      verify: (_) async {
        // Create new BLoC instance with same database
        final newBloc = SshHostBloc(database);
        newBloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 100));

        final state = newBloc.state as SshHostLoaded;
        expect(state.sshHosts.length, 1);
        expect(state.sshHosts.first.host, 'Persistent');
        await newBloc.close();
      },
    );
  });

  group('Complex Scenarios', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    blocTest<SshHostBloc, SshHostState>(
      'Rapid host additions work correctly',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        for (var i = 0; i < 5; i++) {
          bloc.add(SshHostAdd(
            host: 'RapidHost$i',
            hostname: 'rapid$i.com',
            port: 22 + i,
            username: 'user$i',
            identityType: 1,
          ));
          await Future.delayed(const Duration(milliseconds: 10));
        }
      },
      verify: (bloc) async {
        await Future.delayed(const Duration(milliseconds: 100));
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.length, 5);
        expect(state.sshHosts[0].host, 'RapidHost0');
        expect(state.sshHosts[4].host, 'RapidHost4');
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Adding host with same hostname (duplicate) is allowed',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        bloc.add(const SshHostAdd(
          host: 'Server1',
          hostname: 'same.com',
          port: 22,
          username: 'user1',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostAdd(
          host: 'Server2',
          hostname: 'same.com', // Same hostname, different display name
          port: 22,
          username: 'user2',
          identityType: 1,
        ));
      },
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.length, 2);
        expect(state.sshHosts[0].hostname, 'same.com');
        expect(state.sshHosts[1].hostname, 'same.com');
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Add then delete then add sequence works correctly',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        // Add host
        bloc.add(const SshHostAdd(
          host: 'AddDeleteAdd',
          hostname: 'ada.com',
          port: 22,
          username: 'user',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 50));

        // Delete it
        final state1 = bloc.state as SshHostLoaded;
        bloc.add(SshHostDelete(state1.sshHosts.first));
        await Future.delayed(const Duration(milliseconds: 50));

        // Add again
        bloc.add(const SshHostAdd(
          host: 'AddDeleteAdd',
          hostname: 'ada.com',
          port: 22,
          username: 'user',
          identityType: 1,
        ));
      },
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.length, 1);
        expect(state.sshHosts.first.host, 'AddDeleteAdd');
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Load called multiple times with same data emits state only once',
      setUp: () async {
        await database.into(database.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('StaticHost'),
                hostname: const Value('static.com'),
                port: const Value(22),
                username: const Value('user'),
                identityType: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );
      },
      build: () => SshHostBloc(database),
      act: (bloc) async {
        bloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostLoad());
      },
      expect: () => [
        // Only one emission because Equatable prevents duplicate states
        isA<SshHostLoaded>().having((s) => s.sshHosts.length, 'count', 1),
      ],
    );

    blocTest<SshHostBloc, SshHostState>(
      'Mixed identity types (password and key) can coexist',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        bloc.add(const SshHostAdd(
          host: 'PasswordHost',
          hostname: 'pwd.com',
          port: 22,
          username: 'pwduser',
          password: 'encrypted',
          salt: 'salt',
          identityType: 1, // password
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostAdd(
          host: 'KeyHost',
          hostname: 'key.com',
          port: 22,
          username: 'keyuser',
          identityType: 2, // key
          identityKeyId: 10,
        ));
      },
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.length, 2);
        expect(state.sshHosts[0].identityType, 1);
        expect(state.sshHosts[1].identityType, 2);
      },
    );
  });

  group('Edge Cases', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    blocTest<SshHostBloc, SshHostState>(
      'Hostname with special characters is handled',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'SpecialHost',
        hostname: 'server-name_123.sub.domain.com',
        port: 22,
        username: 'user',
        identityType: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.hostname, 'server-name_123.sub.domain.com');
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'IPv6 hostname is handled',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'IPv6Host',
        hostname: '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        port: 22,
        username: 'user',
        identityType: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(
          state.sshHosts.first.hostname,
          '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
        );
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Very long password string is handled',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(SshHostAdd(
        host: 'LongPasswordHost',
        hostname: 'long.com',
        port: 22,
        username: 'user',
        password: 'x' * 1000, // 1000 character password
        salt: 'salt',
        identityType: 1,
      )),
      verify: (bloc) async {
        final state = bloc.state as SshHostLoaded;
        expect(
            (await bloc.credentials.readHostPassword(state.sshHosts.first))
                ?.length,
            1000);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Port boundary value 1 is accepted',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'Port1Host',
        hostname: 'port1.com',
        port: 1,
        username: 'user',
        identityType: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.port, 1);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Port boundary value 65535 is accepted',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'Port65535Host',
        hostname: 'port65535.com',
        port: 65535,
        username: 'user',
        identityType: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.port, 65535);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Username with special characters is handled',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'SpecialUserHost',
        hostname: 'special.com',
        port: 22,
        username: 'user_name-123@domain.com',
        identityType: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.username, 'user_name-123@domain.com');
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Empty password string is stored securely',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'EmptyPasswordHost',
        hostname: 'empty.com',
        port: 22,
        username: 'user',
        password: '',
        salt: 'salt',
        identityType: 1,
      )),
      verify: (bloc) async {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.password, startsWith('vault:ssh:'));
        expect(
            await bloc.credentials.readHostPassword(state.sshHosts.first), '');
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Null password for password auth is handled',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'NullPasswordHost',
        hostname: 'null.com',
        port: 22,
        username: 'user',
        password: null,
        salt: null,
        identityType: 1, // password auth but no password (edge case)
      )),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.password, isNull);
        expect(state.sshHosts.first.identityType, 1);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Unicode in host display name is handled',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: '服务器-😀-测试',
        hostname: 'unicode.com',
        port: 22,
        username: 'user',
        identityType: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.host, '服务器-😀-测试');
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Very long hostname string is handled',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(SshHostAdd(
        host: 'LongHostname',
        hostname: '${'subdomain.' * 20}example.com', // Very long FQDN
        port: 22,
        username: 'user',
        identityType: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.hostname?.contains('subdomain.'), isTrue);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Zero identity key ID is handled',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'ZeroKeyIdHost',
        hostname: 'zero.com',
        port: 22,
        username: 'user',
        identityType: 2,
        identityKeyId: 0, // Edge case: ID 0
      )),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.identityKeyId, 0);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Negative port number is stored as-is (no validation in BLoC)',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'NegativePort',
        hostname: 'negative.com',
        port: -1, // Invalid but BLoC doesn't validate
        username: 'user',
        identityType: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.port, -1);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Port above 65535 is stored as-is (no validation in BLoC)',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostAdd(
        host: 'HighPort',
        hostname: 'high.com',
        port: 99999, // Invalid but BLoC doesn't validate
        username: 'user',
        identityType: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.port, 99999);
      },
    );
  });

  group('Load Event Edge Cases', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    blocTest<SshHostBloc, SshHostState>(
      'Load with empty database returns empty list',
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostLoad()),
      expect: () => [
        const SshHostLoaded([]),
      ],
    );

    blocTest<SshHostBloc, SshHostState>(
      'Load can be called multiple times without issue',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        bloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostLoad());
      },
      expect: () => [
        // Only one emission due to Equatable preventing duplicate states
        const SshHostLoaded([]),
      ],
    );

    blocTest<SshHostBloc, SshHostState>(
      'Load after database manually modified reflects changes',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        // Load empty
        bloc.add(const SshHostLoad());
        await Future.delayed(const Duration(milliseconds: 50));

        // Manually insert into database (simulating external modification)
        await database.into(database.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('ManualHost'),
                hostname: const Value('manual.com'),
                port: const Value(22),
                username: const Value('user'),
                identityType: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );

        // Load again
        bloc.add(const SshHostLoad());
      },
      expect: () => [
        const SshHostLoaded([]),
        isA<SshHostLoaded>().having((s) => s.sshHosts.length, 'count', 1),
      ],
    );

    blocTest<SshHostBloc, SshHostState>(
      'Load with hosts sorted by ID (database order)',
      setUp: () async {
        // Insert in specific order
        await database.into(database.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('HostC'),
                hostname: const Value('c.com'),
                port: const Value(22),
                username: const Value('user'),
                identityType: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );
        await database.into(database.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('HostA'),
                hostname: const Value('a.com'),
                port: const Value(22),
                username: const Value('user'),
                identityType: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );
        await database.into(database.sshHosts).insert(
              SshHostsCompanion.insert(
                host: const Value('HostB'),
                hostname: const Value('b.com'),
                port: const Value(22),
                username: const Value('user'),
                identityType: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );
      },
      build: () => SshHostBloc(database),
      act: (bloc) => bloc.add(const SshHostLoad()),
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        // Order depends on database insertion order (ID order)
        expect(state.sshHosts[0].host, 'HostC');
        expect(state.sshHosts[1].host, 'HostA');
        expect(state.sshHosts[2].host, 'HostB');
      },
    );
  });

  group('State Immutability', () {
    test('SshHostLoaded list is immutable (new list on each creation)', () {
      final hosts1 = [
        SshHost(
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
        ),
      ];
      final state1 = SshHostLoaded(hosts1);

      final hosts2 = [
        SshHost(
          id: 2,
          host: 'Test2',
          hostname: 'test2.com',
          port: 22,
          username: 'user',
          password: null,
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        ),
      ];
      final state2 = SshHostLoaded(hosts2);

      expect(state1.sshHosts, isNot(same(state2.sshHosts)));
      expect(state1, isNot(equals(state2)));
    });

    test('SshHostInitial is const and reusable', () {
      const state1 = SshHostInitial();
      const state2 = SshHostInitial();
      expect(identical(state1, state2), isTrue);
    });

    test('SshHostError with same error message is equal', () {
      const error = 'Test error';
      const state1 = SshHostError(error);
      const state2 = SshHostError(error);
      expect(state1, equals(state2));
    });
  });

  group('SshIdentityType Edge Cases', () {
    test('fromValue returns correct types for valid values', () {
      expect(SshIdentityType.fromValue(1), SshIdentityType.password);
      expect(SshIdentityType.fromValue(2), SshIdentityType.key);
    });

    test('fromValue returns null for zero', () {
      expect(SshIdentityType.fromValue(0), isNull);
    });

    test('fromValue returns null for negative values', () {
      expect(SshIdentityType.fromValue(-1), isNull);
      expect(SshIdentityType.fromValue(-100), isNull);
    });

    test('fromValue returns null for values above 2', () {
      expect(SshIdentityType.fromValue(3), isNull);
      expect(SshIdentityType.fromValue(999), isNull);
    });

    test('password type has value 1', () {
      expect(SshIdentityType.password.value, 1);
    });

    test('key type has value 2', () {
      expect(SshIdentityType.key.value, 2);
    });
  });

  group('Error Handling', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    blocTest<SshHostBloc, SshHostState>(
      'Deleting non-existent host emits SshHostError',
      build: () => SshHostBloc(database),
      act: (bloc) {
        final fakeHost = SshHost(
          id: 999999,
          host: 'Nonexistent',
          hostname: 'nonexistent.com',
          port: 22,
          username: 'user',
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
      'Error state contains error object',
      build: () => SshHostBloc(database),
      act: (bloc) {
        final fakeHost = SshHost(
          id: 999999,
          host: 'Fake',
          hostname: 'fake.com',
          port: 22,
          username: 'user',
          password: null,
          salt: null,
          identityType: 1,
          identityKeyId: null,
          createdAt: DateTime.now(),
        );
        bloc.add(SshHostDelete(fakeHost));
      },
      verify: (bloc) {
        final state = bloc.state as SshHostError;
        expect(state.error, isNotNull);
      },
    );
  });

  group('Timestamps and Auto-Generated Fields', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    blocTest<SshHostBloc, SshHostState>(
      'Added hosts have auto-generated positive IDs',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        bloc.add(const SshHostAdd(
          host: 'AutoID',
          hostname: 'autoid.com',
          port: 22,
          username: 'user',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 100));
      },
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts.first.id, isPositive);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Added hosts have createdAt timestamp',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        bloc.add(const SshHostAdd(
          host: 'TimestampTest',
          hostname: 'timestamp.com',
          port: 22,
          username: 'user',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 100));
      },
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        final createdAt = state.sshHosts.first.createdAt;
        expect(createdAt, isNotNull);
        expect(createdAt!.isBefore(DateTime.now()), isTrue);
      },
    );

    blocTest<SshHostBloc, SshHostState>(
      'Multiple hosts have sequential IDs',
      build: () => SshHostBloc(database),
      act: (bloc) async {
        bloc.add(const SshHostAdd(
          host: 'Host1',
          hostname: 'h1.com',
          port: 22,
          username: 'user',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostAdd(
          host: 'Host2',
          hostname: 'h2.com',
          port: 22,
          username: 'user',
          identityType: 1,
        ));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshHostAdd(
          host: 'Host3',
          hostname: 'h3.com',
          port: 22,
          username: 'user',
          identityType: 1,
        ));
      },
      verify: (bloc) {
        final state = bloc.state as SshHostLoaded;
        expect(state.sshHosts[0].id, lessThan(state.sshHosts[1].id));
        expect(state.sshHosts[1].id, lessThan(state.sshHosts[2].id));
      },
    );
  });
}
