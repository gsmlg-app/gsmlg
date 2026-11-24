import 'package:app_database/app_database.dart';
import 'package:app_duckdb/app_duckdb.dart' show LogStoreClient;
import 'package:app_provider/app_provider.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart' show IsolateHub;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vnc_host_bloc/vnc_host_bloc.dart';

void main() {
  testWidgets('MainProvider provides VncHostBloc on native platforms', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting();
    addTearDown(database.close);
    final vault = _UnusedVault();
    final hub = IsolateHub();

    VncHostBloc? vncHostBloc;

    await tester.pumpWidget(
      MainProvider(
        sharedPrefs: preferences,
        database: database,
        vault: vault,
        hub: hub,
        logStore: LogStoreClient(hub),
        child: Builder(
          builder: (context) {
            vncHostBloc = context.read<VncHostBloc>();
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(vncHostBloc, isNotNull);
    expect(vncHostBloc!.repository.database, same(database));
    expect(vncHostBloc!.repository.vault, same(vault));
    expect(vncHostBloc!.state.isLoading, isFalse);
    expect(vncHostBloc!.state.hosts, isEmpty);
    expect(vncHostBloc!.state.error, isNull);
  });
}

class _UnusedVault implements VaultRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('VNC provider test must not access secure storage');
}
