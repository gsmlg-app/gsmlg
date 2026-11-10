import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/vault_repository.dart';

import '../models/backplane_settings.dart';
import '../repositories/remote_llm_repository.dart';
import '../services/dart_mcp_tool_client.dart';
import '../services/secret_reader.dart';
import '../services/tool_data_source.dart';

class BackplaneServiceRepository {
  /// Pass [data] and [secrets]; [database] and [vault] are main-isolate
  /// conveniences wrapped in [DatabaseToolDataSource] / [VaultSecretReader].
  BackplaneServiceRepository({
    ToolDataSource? data,
    SecretReader? secrets,
    AppDatabase? database,
    VaultRepository? vault,
    required RemoteLlmRepository remoteLlm,
    DartMcpToolClient? mcpClient,
  }) : _data =
           data ??
           DatabaseToolDataSource(
             database ?? (throw ArgumentError('data or database is required')),
           ),
       _secrets =
           secrets ??
           VaultSecretReader(
             vault ?? (throw ArgumentError('secrets or vault is required')),
           ),
       _remoteLlm = remoteLlm,
       _mcpClient = mcpClient ?? DartMcpToolClient();

  final ToolDataSource _data;
  final SecretReader _secrets;
  final RemoteLlmRepository _remoteLlm;
  final DartMcpToolClient _mcpClient;

  Future<String> tokenFor(BackplaneSettings settings) async {
    final id = settings.accountId;
    if (id == null) {
      throw StateError('Select a service account in Backplane settings.');
    }
    final account = await _data.serviceAccountById(id);
    if (account == null) {
      throw StateError(
        'Selected service account is missing. Manage Service Accounts.',
      );
    }
    final token = (await _secrets.read('service_account_$id'))?.trim();
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
