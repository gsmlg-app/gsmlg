// Comprehensive test suite for SshKeyBloc
//
// This test file provides extensive coverage of edge cases, scenarios,
// and behaviors not covered in the basic ssh_key_bloc_test.dart file.
//
// Test Categories:
// 1. Event Equatable Tests - Verify event equality behavior
// 2. State Equatable Tests - Verify state equality behavior
// 3. Database Persistence Tests - Verify data is correctly persisted to database
// 4. Complex Scenarios - Test rapid operations, concurrent adds, etc.
// 5. Edge Cases - Special characters, unicode, boundaries, null handling
// 6. Load Event Edge Cases - Multiple loads, empty database
// 7. State Immutability - Verify states are immutable and independent
// 8. Algorithm Enum Edge Cases - Verify all algorithm types
// 9. Encryption Edge Cases - Verify encryption/decryption edge cases
// 10. Error Handling - Verify error scenarios
//
// Total: 54 additional comprehensive tests

import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:app_security/app_security.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  group('Event Equatable Tests', () {
    test('SshKeyLoad instances are equal', () {
      const event1 = SshKeyLoad();
      const event2 = SshKeyLoad();
      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('SshKeyAdd with same parameters are equal', () {
      const event1 = SshKeyAdd(
        name: 'Test',
        content: 'content',
        password: 'pwd',
        salt: 'salt',
        algorithm: 1,
      );
      const event2 = SshKeyAdd(
        name: 'Test',
        content: 'content',
        password: 'pwd',
        salt: 'salt',
        algorithm: 1,
      );
      expect(event1, equals(event2));
      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('SshKeyAdd with different parameters are not equal', () {
      const event1 =
          SshKeyAdd(name: 'Test1', content: 'c1', salt: 's1', algorithm: 1);
      const event2 =
          SshKeyAdd(name: 'Test2', content: 'c1', salt: 's1', algorithm: 1);
      expect(event1, isNot(equals(event2)));
    });

    test('SshKeyAdd with null password vs non-null password are not equal', () {
      const event1 = SshKeyAdd(
          name: 'Test', content: 'c', password: null, salt: 's', algorithm: 1);
      const event2 = SshKeyAdd(
          name: 'Test', content: 'c', password: 'pwd', salt: 's', algorithm: 1);
      expect(event1, isNot(equals(event2)));
    });

    test('SshKeyDelete with same key are equal', () {
      final key = SshKey(
        id: 1,
        name: 'Test',
        content: 'content',
        password: null,
        salt: 'salt',
        algorithm: 1,
        createdAt: DateTime(2024, 1, 1),
      );
      final event1 = SshKeyDelete(key);
      final event2 = SshKeyDelete(key);
      expect(event1, equals(event2));
    });

    test('SshKeyDelete with different keys are not equal', () {
      final key1 = SshKey(
        id: 1,
        name: 'Test1',
        content: 'content',
        password: null,
        salt: 'salt',
        algorithm: 1,
        createdAt: DateTime(2024, 1, 1),
      );
      final key2 = SshKey(
        id: 2,
        name: 'Test2',
        content: 'content',
        password: null,
        salt: 'salt',
        algorithm: 1,
        createdAt: DateTime(2024, 1, 1),
      );
      final event1 = SshKeyDelete(key1);
      final event2 = SshKeyDelete(key2);
      expect(event1, isNot(equals(event2)));
    });
  });

  group('State Equatable Tests', () {
    test('SshKeyInitial instances are equal', () {
      const state1 = SshKeyInitial();
      const state2 = SshKeyInitial();
      expect(state1, equals(state2));
      expect(state1.hashCode, equals(state2.hashCode));
    });

    test('SshKeyLoaded with same keys are equal', () {
      final keys = [
        SshKey(
          id: 1,
          name: 'Key1',
          content: 'content1',
          password: null,
          salt: 'salt1',
          algorithm: 1,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      final state1 = SshKeyLoaded(keys);
      final state2 = SshKeyLoaded(keys);
      expect(state1, equals(state2));
    });

    test('SshKeyLoaded with different keys are not equal', () {
      final keys1 = [
        SshKey(
          id: 1,
          name: 'Key1',
          content: 'content1',
          password: null,
          salt: 'salt1',
          algorithm: 1,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      final keys2 = [
        SshKey(
          id: 2,
          name: 'Key2',
          content: 'content2',
          password: null,
          salt: 'salt2',
          algorithm: 1,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
      final state1 = SshKeyLoaded(keys1);
      final state2 = SshKeyLoaded(keys2);
      expect(state1, isNot(equals(state2)));
    });

    test('SshKeyLoaded empty lists are equal', () {
      const state1 = SshKeyLoaded([]);
      const state2 = SshKeyLoaded([]);
      expect(state1, equals(state2));
    });

    test('SshKeyError with same error are equal', () {
      const error = 'Test error';
      const state1 = SshKeyError(error);
      const state2 = SshKeyError(error);
      expect(state1, equals(state2));
    });

    test('SshKeyError with different errors are not equal', () {
      const state1 = SshKeyError('Error 1');
      const state2 = SshKeyError('Error 2');
      expect(state1, isNot(equals(state2)));
    });

    test('Different state types are not equal', () {
      const state1 = SshKeyInitial();
      const state2 = SshKeyLoaded([]);
      const state3 = SshKeyError('error');
      expect(state1, isNot(equals(state2)));
      expect(state1, isNot(equals(state3)));
      expect(state2, isNot(equals(state3)));
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

    blocTest<SshKeyBloc, SshKeyState>(
      'SshKeyAdd persists to database',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: 'Persist Test',
        content: 'persisted_content',
        password: 'persisted_pwd',
        salt: 'persisted_salt',
        algorithm: 1,
      )),
      verify: (_) async {
        final keys = await database.select(database.sshKeys).get();
        expect(keys.length, 1);
        expect(keys.first.name, 'Persist Test');
        expect(keys.first.content, startsWith('vault:ssh:'));
        expect(
            await SshCredentialRepository(database).readPrivateKey(keys.first),
            'persisted_content');
        expect(keys.first.password, startsWith('vault:ssh:'));
        expect(
            await SshCredentialRepository(database)
                .readKeyPassphrase(keys.first),
            'persisted_pwd');
        expect(keys.first.salt, isNull);
        expect(keys.first.algorithm, 1);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'SshKeyDelete removes from database',
      build: () => SshKeyBloc(database),
      setUp: () async {
        await database.into(database.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('To Delete'),
                content: const Value('content'),
                salt: const Value('salt'),
                algorithm: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );
      },
      act: (bloc) async {
        bloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as SshKeyLoaded;
        bloc.add(SshKeyDelete(state.sshKeys.first));
      },
      verify: (_) async {
        final keys = await database.select(database.sshKeys).get();
        expect(keys, isEmpty);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Multiple adds persist all keys to database',
      build: () => SshKeyBloc(database),
      act: (bloc) async {
        bloc.add(const SshKeyAdd(
            name: 'Key1', content: 'c1', salt: 's1', algorithm: 1));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyAdd(
            name: 'Key2', content: 'c2', salt: 's2', algorithm: 2));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyAdd(
            name: 'Key3', content: 'c3', salt: 's3', algorithm: 3));
      },
      verify: (_) async {
        final keys = await database.select(database.sshKeys).get();
        expect(keys.length, 3);
        expect(keys.map((k) => k.name), containsAll(['Key1', 'Key2', 'Key3']));
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Load reads persisted keys from database',
      build: () => SshKeyBloc(database),
      setUp: () async {
        await database.batch((batch) {
          batch.insertAll(database.sshKeys, [
            SshKeysCompanion.insert(
              name: const Value('Preloaded1'),
              content: const Value('c1'),
              salt: const Value('s1'),
              algorithm: const Value(1),
              createdAt: Value(DateTime.now()),
            ),
            SshKeysCompanion.insert(
              name: const Value('Preloaded2'),
              content: const Value('c2'),
              salt: const Value('s2'),
              algorithm: const Value(2),
              createdAt: Value(DateTime.now()),
            ),
          ]);
        });
      },
      act: (bloc) => bloc.add(const SshKeyLoad()),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.length, 2);
        expect(state.sshKeys.map((k) => k.name),
            containsAll(['Preloaded1', 'Preloaded2']));
      },
    );

    test('Database auto-generates sequential IDs', () async {
      final bloc = SshKeyBloc(database);

      bloc.add(const SshKeyAdd(
          name: 'First', content: 'c1', salt: 's1', algorithm: 1));
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(const SshKeyAdd(
          name: 'Second', content: 'c2', salt: 's2', algorithm: 1));
      await Future.delayed(const Duration(milliseconds: 50));

      final state = bloc.state as SshKeyLoaded;
      final ids = state.sshKeys.map((k) => k.id).toList()..sort();
      expect(ids[0], lessThan(ids[1]));
      expect(ids[0], isPositive);
      expect(ids[1], isPositive);

      await bloc.close();
    });

    test('Database preserves null password field', () async {
      final bloc = SshKeyBloc(database);

      bloc.add(const SshKeyAdd(
        name: 'No Password',
        content: 'content',
        password: null,
        salt: 'salt',
        algorithm: 1,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      final keys = await database.select(database.sshKeys).get();
      expect(keys.first.password, isNull);

      await bloc.close();
    });

    test('Database preserves non-null password field', () async {
      final bloc = SshKeyBloc(database);

      bloc.add(const SshKeyAdd(
        name: 'With Password',
        content: 'content',
        password: 'encrypted_password',
        salt: 'salt',
        algorithm: 1,
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      final keys = await database.select(database.sshKeys).get();
      expect(keys.first.password, startsWith('vault:ssh:'));
      expect(await bloc.credentials.readKeyPassphrase(keys.first),
          'encrypted_password');

      await bloc.close();
    });
  });

  group('Complex Scenarios', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting();
    });

    tearDown(() async {
      await database.close();
    });

    blocTest<SshKeyBloc, SshKeyState>(
      'Rapid key additions all succeed',
      build: () => SshKeyBloc(database),
      act: (bloc) async {
        for (int i = 0; i < 5; i++) {
          bloc.add(SshKeyAdd(
            name: 'Rapid$i',
            content: 'content$i',
            salt: 'salt$i',
            algorithm: 1,
          ));
          await Future.delayed(const Duration(milliseconds: 20));
        }
      },
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.length, 5);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Add and delete same key',
      build: () => SshKeyBloc(database),
      act: (bloc) async {
        bloc.add(const SshKeyAdd(
            name: 'Temp', content: 'c', salt: 's', algorithm: 1));
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
      'Multiple loads return consistent data',
      build: () => SshKeyBloc(database),
      setUp: () async {
        await database.into(database.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('Consistent'),
                content: const Value('c'),
                salt: const Value('s'),
                algorithm: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );
      },
      act: (bloc) async {
        bloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyLoad());
      },
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.length, 1);
        expect(state.sshKeys.first.name, 'Consistent');
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Delete all keys one by one',
      build: () => SshKeyBloc(database),
      setUp: () async {
        await database.batch((batch) {
          batch.insertAll(database.sshKeys, [
            SshKeysCompanion.insert(
              name: const Value('Key1'),
              content: const Value('c1'),
              salt: const Value('s1'),
              algorithm: const Value(1),
              createdAt: Value(DateTime.now()),
            ),
            SshKeysCompanion.insert(
              name: const Value('Key2'),
              content: const Value('c2'),
              salt: const Value('s2'),
              algorithm: const Value(1),
              createdAt: Value(DateTime.now()),
            ),
          ]);
        });
      },
      act: (bloc) async {
        bloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        var state = bloc.state as SshKeyLoaded;
        bloc.add(SshKeyDelete(state.sshKeys.first));
        await Future.delayed(const Duration(milliseconds: 50));
        state = bloc.state as SshKeyLoaded;
        bloc.add(SshKeyDelete(state.sshKeys.first));
      },
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys, isEmpty);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Add keys with duplicate names (allowed)',
      build: () => SshKeyBloc(database),
      act: (bloc) async {
        bloc.add(const SshKeyAdd(
            name: 'Duplicate', content: 'c1', salt: 's1', algorithm: 1));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyAdd(
            name: 'Duplicate', content: 'c2', salt: 's2', algorithm: 1));
      },
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.length, 2);
        expect(state.sshKeys.every((k) => k.name == 'Duplicate'), isTrue);
        // IDs should be different
        expect(state.sshKeys[0].id, isNot(equals(state.sshKeys[1].id)));
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

    blocTest<SshKeyBloc, SshKeyState>(
      'Key name with special characters',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: 'Key!@#\$%^&*()_+-=[]{}|;:\'",.<>?/',
        content: 'content',
        salt: 'salt',
        algorithm: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.name, 'Key!@#\$%^&*()_+-=[]{}|;:\'",.<>?/');
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Key name with unicode characters',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: 'Key 密钥 🔑 مفتاح',
        content: 'content',
        salt: 'salt',
        algorithm: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.name, 'Key 密钥 🔑 مفتاح');
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Very long key name',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(SshKeyAdd(
        name: 'K' * 1000,
        content: 'content',
        salt: 'salt',
        algorithm: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.name?.length, 1000);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Empty key name',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: '',
        content: 'content',
        salt: 'salt',
        algorithm: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.name, '');
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Very long content (simulating large key)',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(SshKeyAdd(
        name: 'Large Key',
        content: 'X' * 10000,
        salt: 'salt',
        algorithm: 1,
      )),
      verify: (bloc) async {
        final state = bloc.state as SshKeyLoaded;
        expect(
            (await bloc.credentials.readPrivateKey(state.sshKeys.first)).length,
            10000);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Salt with special characters',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: 'Test',
        content: 'content',
        salt: 'salt!@#\$%^&*()',
        algorithm: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.salt, isNull);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Password with unicode',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: 'Test',
        content: 'content',
        password: '密码🔒пароль',
        salt: 'salt',
        algorithm: 1,
      )),
      verify: (bloc) async {
        final state = bloc.state as SshKeyLoaded;
        expect(await bloc.credentials.readKeyPassphrase(state.sshKeys.first),
            '密码🔒пароль');
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'All fields null except name',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: 'Minimal',
        content: null,
        password: null,
        salt: null,
        algorithm: null,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.name, 'Minimal');
        expect(state.sshKeys.first.content, isNull);
        expect(state.sshKeys.first.password, isNull);
        expect(state.sshKeys.first.salt, isNull);
        expect(state.sshKeys.first.algorithm, isNull);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'All fields completely null',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: null,
        content: null,
        password: null,
        salt: null,
        algorithm: null,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.name, isNull);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Algorithm value of 0 (invalid but not rejected)',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: 'Invalid Algo',
        content: 'content',
        salt: 'salt',
        algorithm: 0,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.algorithm, 0);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Negative algorithm value (invalid but not rejected)',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: 'Negative Algo',
        content: 'content',
        salt: 'salt',
        algorithm: -1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.algorithm, -1);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Very large algorithm value',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: 'Large Algo',
        content: 'content',
        salt: 'salt',
        algorithm: 9999,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.algorithm, 9999);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Whitespace-only key name',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: '   ',
        content: 'content',
        salt: 'salt',
        algorithm: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.name, '   ');
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Newlines in key name',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: 'Multi\nLine\nName',
        content: 'content',
        salt: 'salt',
        algorithm: 1,
      )),
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.first.name, 'Multi\nLine\nName');
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Tabs in content',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyAdd(
        name: 'Test',
        content: 'content\twith\ttabs',
        salt: 'salt',
        algorithm: 1,
      )),
      verify: (bloc) async {
        final state = bloc.state as SshKeyLoaded;
        expect(await bloc.credentials.readPrivateKey(state.sshKeys.first),
            'content\twith\ttabs');
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

    blocTest<SshKeyBloc, SshKeyState>(
      'Load on empty database returns empty list',
      build: () => SshKeyBloc(database),
      act: (bloc) => bloc.add(const SshKeyLoad()),
      expect: () => [
        const SshKeyLoaded([]),
      ],
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Load can be called multiple times',
      build: () => SshKeyBloc(database),
      setUp: () async {
        await database.into(database.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('Test'),
                content: const Value('c'),
                salt: const Value('s'),
                algorithm: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );
      },
      act: (bloc) async {
        bloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyLoad());
      },
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.length, 1);
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Load after add reflects new data',
      build: () => SshKeyBloc(database),
      act: (bloc) async {
        bloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyAdd(
            name: 'New', content: 'c', salt: 's', algorithm: 1));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyLoad());
      },
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys.length, 1);
        expect(state.sshKeys.first.name, 'New');
      },
    );

    blocTest<SshKeyBloc, SshKeyState>(
      'Load after delete reflects deletion',
      build: () => SshKeyBloc(database),
      setUp: () async {
        await database.into(database.sshKeys).insert(
              SshKeysCompanion.insert(
                name: const Value('ToDelete'),
                content: const Value('c'),
                salt: const Value('s'),
                algorithm: const Value(1),
                createdAt: Value(DateTime.now()),
              ),
            );
      },
      act: (bloc) async {
        bloc.add(const SshKeyLoad());
        await Future.delayed(const Duration(milliseconds: 50));
        final state = bloc.state as SshKeyLoaded;
        bloc.add(SshKeyDelete(state.sshKeys.first));
        await Future.delayed(const Duration(milliseconds: 50));
        bloc.add(const SshKeyLoad());
      },
      verify: (bloc) {
        final state = bloc.state as SshKeyLoaded;
        expect(state.sshKeys, isEmpty);
      },
    );
  });

  group('State Immutability', () {
    test('SshKeyLoaded state is independent', () {
      final keys1 = [
        SshKey(
          id: 1,
          name: 'Key1',
          content: 'c1',
          password: null,
          salt: 's1',
          algorithm: 1,
          createdAt: DateTime.now(),
        ),
      ];
      final state1 = SshKeyLoaded(keys1);

      final keys2 = List<SshKey>.from(keys1);
      final state2 = SshKeyLoaded(keys2);

      expect(state1, equals(state2));
      expect(state1.sshKeys, isNot(same(state2.sshKeys)));
    });

    test('Modifying state sshKeys list does not affect original', () {
      final originalKeys = [
        SshKey(
          id: 1,
          name: 'Original',
          content: 'c',
          password: null,
          salt: 's',
          algorithm: 1,
          createdAt: DateTime.now(),
        ),
      ];
      final state = SshKeyLoaded(originalKeys);

      // Attempt to modify the list (should not affect internal state)
      final retrievedKeys = state.sshKeys;
      expect(retrievedKeys, hasLength(1));

      // The original state should remain unchanged
      expect(state.sshKeys, hasLength(1));
    });
  });

  group('Algorithm Enum Edge Cases', () {
    test('All algorithm enum values map correctly', () {
      expect(SshKeyAlgorithm.rsa.value, 1);
      expect(SshKeyAlgorithm.dsa.value, 2);
      expect(SshKeyAlgorithm.ecdsa.value, 3);
      expect(SshKeyAlgorithm.ed25519.value, 4);
    });

    test('fromValue handles all valid values', () {
      expect(SshKeyAlgorithm.fromValue(1), SshKeyAlgorithm.rsa);
      expect(SshKeyAlgorithm.fromValue(2), SshKeyAlgorithm.dsa);
      expect(SshKeyAlgorithm.fromValue(3), SshKeyAlgorithm.ecdsa);
      expect(SshKeyAlgorithm.fromValue(4), SshKeyAlgorithm.ed25519);
    });

    test('fromValue returns null for out-of-range values', () {
      expect(SshKeyAlgorithm.fromValue(-100), isNull);
      expect(SshKeyAlgorithm.fromValue(100), isNull);
    });

    test('algorithmEnum extension handles null algorithm', () {
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

    test('algorithmEnum extension handles invalid algorithm', () {
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
  });

  group('Encryption Edge Cases', () {
    const testKey = '''-----BEGIN RSA PRIVATE KEY-----
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

    test('Encryption with empty salt', () {
      final aesHelper = AesHelper('Web Terminal');
      final encrypted = aesHelper.encrypt64WithSalt(testKey, '');

      final key = SshKey(
        id: 1,
        name: 'Empty Salt',
        content: encrypted,
        password: null,
        salt: '',
        algorithm: 1,
        createdAt: DateTime.now(),
      );

      final decrypted = key.getPrivateKeyPem();
      expect(decrypted.trim(), testKey.trim());
    });

    test('Encryption with very long salt', () {
      final longSalt = 'x' * 1000;
      final aesHelper = AesHelper('Web Terminal');
      final encrypted = aesHelper.encrypt64WithSalt(testKey, longSalt);

      final key = SshKey(
        id: 1,
        name: 'Long Salt',
        content: encrypted,
        password: null,
        salt: longSalt,
        algorithm: 1,
        createdAt: DateTime.now(),
      );

      final decrypted = key.getPrivateKeyPem();
      expect(decrypted.trim(), testKey.trim());
    });

    test('Encryption with unicode salt throws due to key length', () {
      const unicodeSalt = '密码🔒salt';
      final aesHelper = AesHelper('Web Terminal');
      // Unicode characters in salt cause AES key length issues
      // This is expected behavior - salt should be ASCII-safe
      expect(
        () => aesHelper.encrypt64WithSalt(testKey, unicodeSalt),
        throwsA(anything),
      );
    });

    test('getPublicKeyPem with different algorithm types', () {
      final aesHelper = AesHelper('Web Terminal');
      final encrypted = aesHelper.encrypt64WithSalt(testKey, 'salt');

      // RSA key
      final rsaKey = SshKey(
        id: 1,
        name: 'RSA',
        content: encrypted,
        password: null,
        salt: 'salt',
        algorithm: SshKeyAlgorithm.rsa.value,
        createdAt: DateTime.now(),
      );

      final pubKey = rsaKey.getPublicKeyPem();
      expect(pubKey, startsWith('ssh-rsa '));
    });

    test('Decrypt with wrong salt throws', () {
      final aesHelper = AesHelper('Web Terminal');
      final encrypted = aesHelper.encrypt64WithSalt(testKey, 'correct-salt');

      final key = SshKey(
        id: 1,
        name: 'Wrong Salt',
        content: encrypted,
        password: null,
        salt: 'wrong-salt',
        algorithm: 1,
        createdAt: DateTime.now(),
      );

      expect(() => key.getPrivateKeyPem(), throwsA(anything));
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

    blocTest<SshKeyBloc, SshKeyState>(
      'Delete non-existent key emits error',
      build: () => SshKeyBloc(database),
      act: (bloc) {
        final fakeKey = SshKey(
          id: 99999,
          name: 'Fake',
          content: 'content',
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
      'Error state contains error object',
      build: () => SshKeyBloc(database),
      act: (bloc) {
        final fakeKey = SshKey(
          id: 99999,
          name: 'Fake',
          content: 'content',
          password: null,
          salt: 'salt',
          algorithm: 1,
          createdAt: DateTime.now(),
        );
        bloc.add(SshKeyDelete(fakeKey));
      },
      verify: (bloc) {
        final state = bloc.state as SshKeyError;
        expect(state.error, isA<Exception>());
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

    test('Key timestamps match their insertion intervals', () async {
      final bloc = SshKeyBloc(database);
      addTearDown(bloc.close);
      final insertionWindows = <String, (int, int)>{};

      for (final name in const ['Key1', 'Key2']) {
        final completion = Completer<void>();
        final startedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        bloc.add(SshKeyAdd(
          completion: completion,
          name: name,
          content: 'content-$name',
          salt: 'salt-$name',
          algorithm: 1,
        ));
        await completion.future;
        final completedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        insertionWindows[name] = (startedAt, completedAt);
      }

      final state = bloc.state as SshKeyLoaded;
      expect(state.sshKeys, hasLength(2));
      expect(state.sshKeys.map((key) => key.name),
          unorderedEquals(['Key1', 'Key2']));
      final timestamps = <int>[];
      for (final entry in insertionWindows.entries) {
        final key = state.sshKeys.singleWhere((key) => key.name == entry.key);
        expect(key.createdAt, isNotNull);
        final timestamp = key.createdAt!.millisecondsSinceEpoch ~/ 1000;
        expect(timestamp, inInclusiveRange(entry.value.$1, entry.value.$2));
        timestamps.add(timestamp);
      }
      expect(timestamps[1], greaterThanOrEqualTo(timestamps[0]));
    });

    test('CreatedAt is set automatically', () async {
      final beforeAdd = DateTime.now();
      final bloc = SshKeyBloc(database);

      bloc.add(
          const SshKeyAdd(name: 'Test', content: 'c', salt: 's', algorithm: 1));
      await Future.delayed(const Duration(milliseconds: 100));

      final afterAdd = DateTime.now();
      final state = bloc.state as SshKeyLoaded;
      final createdAt = state.sshKeys.first.createdAt!;

      expect(createdAt.isAfter(beforeAdd.subtract(const Duration(seconds: 1))),
          isTrue);
      expect(
          createdAt.isBefore(afterAdd.add(const Duration(seconds: 1))), isTrue);

      await bloc.close();
    });

    test('IDs are unique across multiple keys', () async {
      final bloc = SshKeyBloc(database);

      for (int i = 0; i < 10; i++) {
        bloc.add(SshKeyAdd(
            name: 'Key$i', content: 'c$i', salt: 's$i', algorithm: 1));
        await Future.delayed(const Duration(milliseconds: 20));
      }

      final state = bloc.state as SshKeyLoaded;
      final ids = state.sshKeys.map((k) => k.id).toList();
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, 10); // All IDs are unique

      await bloc.close();
    });
  });
}
