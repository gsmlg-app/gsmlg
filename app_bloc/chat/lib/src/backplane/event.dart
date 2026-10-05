part of 'bloc.dart';

sealed class BackplaneSettingsEvent {
  const BackplaneSettingsEvent();
}

final class BackplaneSave extends BackplaneSettingsEvent {
  const BackplaneSave({
    required this.serviceUrl,
    required this.accountId,
    required this.apiType,
    required this.mcpEnabled,
  });

  final String serviceUrl;
  final int? accountId;
  final RemoteLlmApiType apiType;
  final bool mcpEnabled;
}

final class BackplaneLoadModels extends BackplaneSettingsEvent {
  const BackplaneLoadModels();
}

final class BackplaneRefreshTools extends BackplaneSettingsEvent {
  const BackplaneRefreshTools();
}
