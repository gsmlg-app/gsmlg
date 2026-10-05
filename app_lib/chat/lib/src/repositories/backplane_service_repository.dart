import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/vault_repository.dart';

import '../models/backplane_settings.dart';
import '../repositories/remote_llm_repository.dart';
import '../services/dart_mcp_tool_client.dart';

class BackplaneServiceRepository {
  BackplaneServiceRepository({
    required AppDatabase database,
    required VaultRepository vault,
    required RemoteLlmRepository remoteLlm,
    DartMcpToolClient? mcpClient,
  }) : _database = database,
       _vault = vault,
       _remoteLlm = remoteLlm,
       _mcpClient = mcpClient ?? DartMcpToolClient();

  final AppDatabase _database;
  final VaultRepository _vault;
  final RemoteLlmRepository _remoteLlm;
  final DartMcpToolClient _mcpClient;

  Future<String> tokenFor(BackplaneSettings settings) async {
    final id = settings.accountId;
    if (id == null) {
      throw StateError('Select a service account in Backplane settings.');
    }
    final account = await (_database.select(
      _database.serviceAccountTable,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (account == null) {
      throw StateError(
        'Selected service account is missing. Manage Service Accounts.',
      );
    }
    final token = (await _vault.read(key: 'service_account_$id'))?.trim();
    if (token == null || token.isEmpty) {
      throw StateError(
        'Selected service account has no token. Manage Service Accounts.',
      );
    }
    return token;
  }

  Future<List<String>> loadModels(BackplaneSettings settings) async {
    await tokenFor(settings);
    return _remoteLlm
        .listModels(settings.modelConfig(''))
        .timeout(const Duration(seconds: 15));
  }

  Future<List<Map<String, dynamic>>> refreshTools(
    BackplaneSettings settings,
  ) async {
    final token = await tokenFor(settings);
    return _mcpClient
        .listHttpTools(
          DartMcpHttpServerConfig(
            url: settings.mcpUrl,
            headers: {'Authorization': 'Bearer $token'},
          ),
        )
        .timeout(const Duration(seconds: 15));
  }
}
