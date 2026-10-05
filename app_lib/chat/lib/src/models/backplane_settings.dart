import 'model_config.dart';
import 'inference.dart';

class BackplaneSettings {
  const BackplaneSettings({
    this.serviceUrl = 'https://backplane.gsmlg.net',
    this.accountId,
    this.apiType = RemoteLlmApiType.openAiResponses,
    this.mcpEnabled = false,
    this.models = const [],
    this.tools = const [],
  });

  static const managedId = 'backplane';

  final String serviceUrl;
  final int? accountId;
  final RemoteLlmApiType apiType;
  final bool mcpEnabled;
  final List<String> models;
  final List<Map<String, dynamic>> tools;

  Uri get serviceUri => Uri.parse(serviceUrl);
  String get apiBaseUrl => _endpoint('v1');
  String get mcpUrl => _endpoint('mcp');

  String _endpoint(String suffix) {
    final uri = serviceUri;
    final prefix = uri.path.replaceAll(RegExp(r'/+$'), '');
    return uri.replace(path: '$prefix/$suffix').toString();
  }

  static String? validateUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return 'Enter an HTTP or HTTPS service URL without credentials, query, or fragment.';
    }
    return null;
  }

  BackplaneSettings copyWith({
    String? serviceUrl,
    int? accountId,
    bool clearAccount = false,
    RemoteLlmApiType? apiType,
    bool? mcpEnabled,
    List<String>? models,
    List<Map<String, dynamic>>? tools,
  }) => BackplaneSettings(
    serviceUrl: serviceUrl ?? this.serviceUrl,
    accountId: clearAccount ? null : accountId ?? this.accountId,
    apiType: apiType ?? this.apiType,
    mcpEnabled: mcpEnabled ?? this.mcpEnabled,
    models: models ?? this.models,
    tools: tools ?? this.tools,
  );

  Map<String, dynamic> toJson() => {
    'serviceUrl': serviceUrl,
    'accountId': accountId,
    'apiType': apiType.name,
    'mcpEnabled': mcpEnabled,
    'models': models,
    'tools': tools,
  };

  factory BackplaneSettings.fromJson(Map<String, dynamic> json) {
    final apiName = json['apiType'];
    return BackplaneSettings(
      serviceUrl:
          json['serviceUrl'] as String? ?? const BackplaneSettings().serviceUrl,
      accountId: json['accountId'] as int?,
      apiType: RemoteLlmApiType.values.firstWhere(
        (value) => value.name == apiName,
        orElse: () => RemoteLlmApiType.openAiResponses,
      ),
      mcpEnabled: json['mcpEnabled'] as bool? ?? false,
      models: (json['models'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      tools: (json['tools'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(),
    );
  }

  ModelConfig modelConfig(String model, {ModelConfig? base}) =>
      (base ?? ModelConfig.defaultConfig).copyWith(
        inferenceMode: ChatInferenceMode.remote,
        remoteProvider: RemoteLlmProvider.openAi,
        remoteApiType: apiType,
        remoteAccountId: accountId,
        clearRemoteAccount: accountId == null,
        remoteBaseUrl: apiBaseUrl,
        remoteModel: model,
        remoteAuthType: RemoteAuthType.bearerToken,
        clearRemoteAuthHeaderName: true,
        managedRemoteId: managedId,
      );

  Map<String, dynamic>? get mcpProfile =>
      mcpEnabled && accountId != null && tools.isNotEmpty
      ? {
          'id': managedId,
          'name': 'Backplane',
          'url': mcpUrl,
          'transport': 'http',
          'enabled': true,
          'accountId': accountId,
          'authType': RemoteAuthType.bearerToken.name,
          'tools': tools,
        }
      : null;
}
