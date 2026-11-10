import 'package:app_agent/app_agent.dart';
import 'package:app_database/app_database.dart';
import 'package:app_duckdb/app_duckdb.dart' show LogStoreClient;
import 'package:app_provider/app_provider.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart' show IsolateHub;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('agent runs go to an AgentHost; an unavailable hub fails them', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final database = AppDatabase.forTesting();
    addTearDown(database.close);
    // Never started: spawning an agent isolate fails.
    final hub = IsolateHub();
    late AgentHost host;

    await tester.pumpWidget(
      MainProvider(
        sharedPrefs: preferences,
        database: database,
        vault: _EmptyVault(),
        hub: hub,
        logStore: LogStoreClient(hub),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              host = context.read<AgentHost>();
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    final events = await tester.runAsync(
      () => host
          .runStream(
            agentId: 'a',
            runId: 'r1',
            sessionId: 's1',
            modelConfig: const ModelConfig(
              inferenceMode: ChatInferenceMode.remote,
              remoteBaseUrl: 'http://127.0.0.1:9/v1',
              remoteModel: 'm',
            ),
            historyMessages: const [],
            userPrompt: 'hi',
          )
          .toList()
          .timeout(const Duration(seconds: 15)),
    );
    expect(events!.last, isA<AgentRunFailedEvent>());

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _EmptyVault implements VaultRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('unexpected vault access');
}
