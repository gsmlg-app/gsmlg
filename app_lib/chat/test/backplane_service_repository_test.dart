import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses one service account for model and MCP discovery', () async {
    final database = AppDatabase.forTesting();
    addTearDown(database.close);
    final accountId = await database
        .into(database.serviceAccountTable)
        .insert(
          ServiceAccountTableCompanion.insert(
            provider: ServiceProvider.openai,
            name: 'Backplane token',
          ),
        );
    final vault = _MemoryVault();
    await vault.write(key: 'service_account_$accountId', value: 'secret');
    final remote = _Remote();
    final mcp = _Mcp();
    final repository = BackplaneServiceRepository(
      database: database,
      vault: vault,
      remoteLlm: remote,
      mcpClient: mcp,
    );
    final settings = BackplaneSettings(
      serviceUrl: 'https://example.com/team',
      accountId: accountId,
    );

    expect(await repository.loadModels(settings), ['model-a']);
    expect(remote.config!.remoteAccountId, accountId);
    expect(remote.config!.remoteBaseUrl, 'https://example.com/team/v1');
    expect(remote.config!.remoteAuthType, RemoteAuthType.bearerToken);
    expect(await repository.refreshTools(settings), [
      {'name': 'lookup'},
    ]);
    expect(mcp.config!.url, 'https://example.com/team/mcp');
    expect(mcp.config!.headers, {'Authorization': 'Bearer secret'});

    await database.delete(database.serviceAccountTable).go();
    await expectLater(
      repository.loadModels(settings),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      repository.refreshTools(settings),
      throwsA(isA<StateError>()),
    );
    expect(remote.calls, 1);
    expect(mcp.calls, 1);
  });
}

class _Remote implements RemoteLlmRepository {
  ModelConfig? config;
  int calls = 0;

  @override
  Future<List<String>> listModels(ModelConfig config) async {
    this.config = config;
    calls++;
    return ['model-a'];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Mcp extends DartMcpToolClient {
  DartMcpHttpServerConfig? config;
  int calls = 0;

  @override
  Future<List<Map<String, dynamic>>> listHttpTools(
    DartMcpHttpServerConfig config,
  ) async {
    this.config = config;
    calls++;
    return [
      {'name': 'lookup'},
    ];
  }
}

class _MemoryVault implements VaultRepository {
  final Map<String, String> values = {};

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
