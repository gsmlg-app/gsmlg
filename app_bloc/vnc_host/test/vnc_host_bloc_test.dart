import 'dart:async';

import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:app_vnc/app_vnc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vnc_host_bloc/vnc_host_bloc.dart';

class FakeVaultRepository implements VaultRepository {
  final Map<String, String> storage = {};
  bool failWrites = false;
  bool failDeletes = false;

  @override
  Future<void> write({required String key, required String value}) async {
    if (failWrites) {
      throw StateError('Vault write failed');
    }
    storage[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => storage[key];

  @override
  Future<void> delete({required String key}) async {
    if (failDeletes) {
      throw StateError('Vault delete failed');
    }
    storage.remove(key);
  }

  @override
  Future<bool> containsKey({required String key}) async =>
      storage.containsKey(key);

  @override
  Future<void> deleteAll() async => storage.clear();

  @override
  Future<Map<String, String>> readAll() async => Map.unmodifiable(storage);
}

class FakeVncMdnsDiscovery extends VncMdnsDiscovery {
  FakeVncMdnsDiscovery(this._discover);

  final Stream<VncDiscoveredHost> Function(Duration timeout) _discover;
  final List<Duration> requestedTimeouts = [];

  @override
  Stream<VncDiscoveredHost> discover({
    Duration timeout = const Duration(seconds: 5),
  }) {
    requestedTimeouts.add(timeout);
    return _discover(timeout);
  }
}

void main() {
  late AppDatabase database;
  late FakeVaultRepository vault;
  late VncHostRepository repository;

  setUp(() {
    database = AppDatabase.forTesting();
    vault = FakeVaultRepository();
    repository = VncHostRepository(database: database, vault: vault);
  });

  tearDown(() async {
    await database.close();
  });

  group('VncHostRepository', () {
    test(
      'addHost stores password in vault (not SQLite) and readPassword reads it',
      () async {
        final created = await repository.addHost(
          name: 'Mac Studio',
          host: '192.168.1.50',
          port: 5900,
          authType: VncHostAuthType.appleArd,
          username: 'alice',
          password: 'super-secret-password',
          viewOnly: true,
        );

        final expectedKey = VncHostRepository.passwordKey(created.id);
        expect(expectedKey, 'vnc_host:${created.id}:password');
        expect(created.passwordRef, expectedKey);
        expect(created.authType, VncHostAuthType.appleArd.value);
        expect(created.username, 'alice');
        expect(created.viewOnly, isTrue);

        // Secret is in vault, never stored in plaintext in SQLite.
        expect(vault.storage[expectedKey], 'super-secret-password');
        final rawRow = await (database.select(
          database.vncHosts,
        )..where((t) => t.id.equals(created.id))).getSingle();
        expect(rawRow.passwordRef, expectedKey);
        expect(rawRow.passwordRef, isNot(contains('super-secret-password')));

        expect(await repository.readPassword(created), 'super-secret-password');
      },
    );

    test('addHost without password leaves passwordRef null', () async {
      final created = await repository.addHost(
        name: 'No Auth Host',
        host: '10.0.0.5',
        authType: VncHostAuthType.none,
      );

      expect(created.passwordRef, isNull);
      expect(vault.storage, isEmpty);
      expect(await repository.readPassword(created), isNull);
    });

    test('addHost rolls back DB row when vault write fails', () async {
      vault.failWrites = true;

      await expectLater(
        repository.addHost(
          name: 'Broken Vault Host',
          host: '10.0.0.9',
          password: 'secret',
        ),
        throwsStateError,
      );

      final rows = await database.select(database.vncHosts).get();
      expect(rows, isEmpty);
      expect(vault.storage, isEmpty);
    });

    test(
      'updateHost preserves, replaces, and clears password according to flags',
      () async {
        final created = await repository.addHost(
          name: 'Workstation',
          host: '192.168.1.10',
          password: 'initial-password',
        );
        final key = VncHostRepository.passwordKey(created.id);

        // 1. Preserve when password is null and clearPassword is false.
        final preserved = await repository.updateHost(
          created.id,
          name: 'Workstation Renamed',
          host: '192.168.1.11',
          port: 5901,
          authType: VncHostAuthType.vncPassword,
        );
        expect(preserved.name, 'Workstation Renamed');
        expect(preserved.host, '192.168.1.11');
        expect(preserved.port, 5901);
        expect(preserved.passwordRef, key);
        expect(await repository.readPassword(preserved), 'initial-password');

        // 2. Replace when a new non-empty password is provided.
        final replaced = await repository.updateHost(
          created.id,
          name: 'Workstation Renamed',
          host: '192.168.1.11',
          port: 5901,
          password: 'updated-password',
        );
        expect(replaced.passwordRef, key);
        expect(vault.storage[key], 'updated-password');
        expect(await repository.readPassword(replaced), 'updated-password');

        // 3. Clear when clearPassword is true.
        final cleared = await repository.updateHost(
          created.id,
          name: 'Workstation Renamed',
          host: '192.168.1.11',
          port: 5901,
          clearPassword: true,
        );
        expect(cleared.passwordRef, isNull);
        expect(vault.storage.containsKey(key), isFalse);
        expect(await repository.readPassword(cleared), isNull);
      },
    );

    test('deleteHost removes DB row and vault entry', () async {
      final created = await repository.addHost(
        name: 'Temp Host',
        host: '192.168.1.20',
        password: 'temp-password',
      );
      final key = VncHostRepository.passwordKey(created.id);
      expect(vault.storage.containsKey(key), isTrue);

      await repository.deleteHost(created);

      expect(await repository.loadHosts(), isEmpty);
      expect(vault.storage.containsKey(key), isFalse);
    });

    test('deleteHost swallows vault delete errors after DB delete', () async {
      final created = await repository.addHost(
        name: 'Vault Error Host',
        host: '192.168.1.21',
        password: 'pw',
      );
      vault.failDeletes = true;

      await repository.deleteHost(created);

      expect(await repository.loadHosts(), isEmpty);
    });

    test(
      'markConnected sets lastConnectedAt and loadHosts orders connected first',
      () async {
        final first = await repository.addHost(name: 'First', host: '10.0.0.1');
        final second = await repository.addHost(
          name: 'Second',
          host: '10.0.0.2',
        );

        expect(first.lastConnectedAt, isNull);
        expect(second.lastConnectedAt, isNull);

        await repository.markConnected(first.id);

        final loaded = await repository.loadHosts();
        expect(loaded.map((h) => h.id).toList(), [first.id, second.id]);
        expect(loaded.first.lastConnectedAt, isNotNull);
        expect(loaded.last.lastConnectedAt, isNull);
      },
    );
  });

  group('VncHostBloc', () {
    test(
      'VncHostAdd stores password in vault and exposes host in state',
      () async {
        final bloc = VncHostBloc(repository: repository);
        addTearDown(bloc.close);

        final updated = bloc.stream.firstWhere((s) => s.hosts.length == 1);
        bloc.add(
          const VncHostAdd(
            name: 'Office Mac',
            host: '192.168.0.42',
            port: 5900,
            authType: VncHostAuthType.appleArd,
            username: 'bob',
            password: 'my-vnc-password',
          ),
        );

        final state = await updated;
        final saved = state.hosts.single;
        expect(saved.name, 'Office Mac');
        expect(saved.passwordRef, 'vnc_host:${saved.id}:password');
        expect(
          vault.storage['vnc_host:${saved.id}:password'],
          'my-vnc-password',
        );
        expect(await repository.readPassword(saved), 'my-vnc-password');
      },
    );

    test(
      'VncHostUpdate preserves, replaces, and clears password via bloc',
      () async {
        final bloc = VncHostBloc(repository: repository);
        addTearDown(bloc.close);

        final created = await repository.addHost(
          name: 'Dev Box',
          host: '10.0.1.2',
          password: 'pw1',
        );

        // Preserve password when password == null.
        final afterPreserve = bloc.stream.firstWhere(
          (s) => s.hosts.isNotEmpty && s.hosts.single.name == 'Dev Box 2',
        );
        bloc.add(
          VncHostUpdate(id: created.id, name: 'Dev Box 2', host: '10.0.1.2'),
        );
        final preservedState = await afterPreserve;
        expect(
          await repository.readPassword(preservedState.hosts.single),
          'pw1',
        );

        // Replace password.
        final afterReplace = bloc.stream.firstWhere(
          (s) => s.hosts.isNotEmpty && s.hosts.single.port == 5902,
        );
        bloc.add(
          VncHostUpdate(
            id: created.id,
            name: 'Dev Box 2',
            host: '10.0.1.2',
            port: 5902,
            password: 'pw2',
          ),
        );
        final replacedState = await afterReplace;
        expect(
          await repository.readPassword(replacedState.hosts.single),
          'pw2',
        );

        // Clear password.
        final afterClear = bloc.stream.firstWhere(
          (s) => s.hosts.isNotEmpty && s.hosts.single.passwordRef == null,
        );
        bloc.add(
          VncHostUpdate(
            id: created.id,
            name: 'Dev Box 2',
            host: '10.0.1.2',
            port: 5902,
            clearPassword: true,
          ),
        );
        final clearedState = await afterClear;
        expect(clearedState.hosts.single.passwordRef, isNull);
        expect(
          await repository.readPassword(clearedState.hosts.single),
          isNull,
        );
        expect(vault.storage, isEmpty);
      },
    );

    test('VncHostDelete removes DB row and vault password', () async {
      final bloc = VncHostBloc(repository: repository);
      addTearDown(bloc.close);

      final created = await repository.addHost(
        name: 'Delete Me',
        host: '10.0.2.3',
        password: 'delete-secret',
      );
      final key = VncHostRepository.passwordKey(created.id);
      expect(vault.storage[key], 'delete-secret');

      bloc.add(const VncHostLoad());
      await bloc.stream.firstWhere((s) => !s.isLoading && s.hosts.length == 1);

      final afterDelete = bloc.stream.firstWhere((s) => s.hosts.isEmpty);
      bloc.add(VncHostDelete(created));
      await afterDelete;

      expect(await database.select(database.vncHosts).get(), isEmpty);
      expect(vault.storage.containsKey(key), isFalse);
    });

    test('VncHostMarkConnected updates lastConnectedAt', () async {
      final bloc = VncHostBloc(repository: repository);
      addTearDown(bloc.close);

      final created = await repository.addHost(
        name: 'Recent Host',
        host: '10.0.3.4',
      );
      expect(created.lastConnectedAt, isNull);

      final updated = bloc.stream.firstWhere(
        (s) => s.hosts.isNotEmpty && s.hosts.single.lastConnectedAt != null,
      );
      bloc.add(VncHostMarkConnected(created.id));

      final state = await updated;
      expect(state.hosts.single.lastConnectedAt, isNotNull);
    });

    blocTest<VncHostBloc, VncHostState>(
      'VncHostDiscoverLan emits isDiscovering, streams deduplicated hosts incrementally, and finishes',
      build: () {
        const host1 = VncDiscoveredHost(
          name: 'Studio',
          host: 'studio.local',
          port: 5900,
          addresses: ['192.168.1.50'],
        );
        const host1Dup = VncDiscoveredHost(
          name: 'Studio Duplicate',
          host: 'studio.local',
          port: 5900,
          addresses: ['192.168.1.50'],
        );
        const host2 = VncDiscoveredHost(
          name: 'Pi',
          host: 'pi.local',
          port: 5901,
          addresses: ['192.168.1.60'],
        );
        final discovery = FakeVncMdnsDiscovery(
          (_) => Stream.fromIterable([host1, host1Dup, host2]),
        );
        return VncHostBloc(repository: repository, discovery: discovery);
      },
      act: (bloc) =>
          bloc.add(const VncHostDiscoverLan(timeout: Duration(seconds: 2))),
      expect: () => [
        const VncHostState(isDiscovering: true, discoveredHosts: []),
        const VncHostState(
          isDiscovering: true,
          discoveredHosts: [
            VncDiscoveredHost(
              name: 'Studio',
              host: 'studio.local',
              port: 5900,
              addresses: ['192.168.1.50'],
            ),
          ],
        ),
        const VncHostState(
          isDiscovering: true,
          discoveredHosts: [
            VncDiscoveredHost(
              name: 'Studio',
              host: 'studio.local',
              port: 5900,
              addresses: ['192.168.1.50'],
            ),
            VncDiscoveredHost(
              name: 'Pi',
              host: 'pi.local',
              port: 5901,
              addresses: ['192.168.1.60'],
            ),
          ],
        ),
        const VncHostState(
          isDiscovering: false,
          discoveredHosts: [
            VncDiscoveredHost(
              name: 'Studio',
              host: 'studio.local',
              port: 5900,
              addresses: ['192.168.1.50'],
            ),
            VncDiscoveredHost(
              name: 'Pi',
              host: 'pi.local',
              port: 5901,
              addresses: ['192.168.1.60'],
            ),
          ],
        ),
      ],
    );

    test(
      'concurrent VncHostDiscoverLan cancels previous scan and ignores stale hosts',
      () async {
        final firstController = StreamController<VncDiscoveredHost>();
        final secondController = StreamController<VncDiscoveredHost>();
        var firstCancelled = false;
        firstController.onCancel = () {
          firstCancelled = true;
        };

        var callCount = 0;
        final discovery = FakeVncMdnsDiscovery((_) {
          callCount++;
          return callCount == 1
              ? firstController.stream
              : secondController.stream;
        });

        final bloc = VncHostBloc(repository: repository, discovery: discovery);
        addTearDown(() async {
          await bloc.close();
          if (!firstController.isClosed) await firstController.close();
          if (!secondController.isClosed) await secondController.close();
        });

        const staleHost = VncDiscoveredHost(
          name: 'Stale',
          host: 'stale.local',
          port: 5900,
          addresses: ['192.168.1.99'],
        );
        const freshHost = VncDiscoveredHost(
          name: 'Fresh',
          host: 'fresh.local',
          port: 5900,
          addresses: ['192.168.1.100'],
        );

        bloc.add(const VncHostDiscoverLan());
        await bloc.stream.firstWhere((s) => s.isDiscovering);
        firstController.add(staleHost);
        await bloc.stream.firstWhere(
          (s) => s.discoveredHosts.contains(staleHost),
        );

        // Start a second scan before the first finishes.
        final resetFuture = bloc.stream.firstWhere(
          (s) => s.isDiscovering && s.discoveredHosts.isEmpty,
        );
        bloc.add(const VncHostDiscoverLan());
        await resetFuture;

        expect(firstCancelled, isTrue);

        secondController.add(freshHost);
        await bloc.stream.firstWhere(
          (s) => s.discoveredHosts.contains(freshHost),
        );

        final doneFuture = bloc.stream.firstWhere((s) => !s.isDiscovering);
        await secondController.close();
        final finalState = await doneFuture;

        expect(finalState.discoveredHosts, [freshHost]);
        expect(finalState.isDiscovering, isFalse);
      },
    );

    test('bloc.close() cancels active LAN discovery subscription', () async {
      var cancelled = false;
      final controller = StreamController<VncDiscoveredHost>(
        onCancel: () {
          cancelled = true;
        },
      );
      final discovery = FakeVncMdnsDiscovery((_) => controller.stream);
      final bloc = VncHostBloc(repository: repository, discovery: discovery);

      bloc.add(const VncHostDiscoverLan());
      await bloc.stream.firstWhere((s) => s.isDiscovering);
      expect(controller.hasListener, isTrue);

      await bloc.close();

      expect(cancelled, isTrue);
      expect(controller.hasListener, isFalse);
      await controller.close();
    });

    test('VncHostAdd emits error when vault write fails', () async {
      vault.failWrites = true;
      final bloc = VncHostBloc(repository: repository);
      addTearDown(bloc.close);

      final errored = bloc.stream.firstWhere((s) => s.error != null);
      bloc.add(
        const VncHostAdd(
          name: 'Fail Host',
          host: '10.0.9.9',
          password: 'secret',
        ),
      );

      final errorState = await errored;
      expect(errorState.error, isA<StateError>());
      expect(errorState.hosts, isEmpty);
      expect(await database.select(database.vncHosts).get(), isEmpty);
    });
  });
}
