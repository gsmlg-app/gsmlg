part of 'bloc.dart';

class BackplaneSettingsState extends Equatable {
  const BackplaneSettingsState({
    required this.settings,
    this.modelsLoading = false,
    this.toolsLoading = false,
    this.modelsError,
    this.toolsError,
    this.saveError,
  });

  final BackplaneSettings settings;
  final bool modelsLoading;
  final bool toolsLoading;
  final String? modelsError;
  final String? toolsError;
  final String? saveError;

  BackplaneSettingsState copyWith({
    BackplaneSettings? settings,
    bool? modelsLoading,
    bool? toolsLoading,
    String? modelsError,
    String? toolsError,
    String? saveError,
    bool clearModelsError = false,
    bool clearToolsError = false,
  }) =>
      BackplaneSettingsState(
        settings: settings ?? this.settings,
        modelsLoading: modelsLoading ?? this.modelsLoading,
        toolsLoading: toolsLoading ?? this.toolsLoading,
        modelsError: clearModelsError ? null : modelsError ?? this.modelsError,
        toolsError: clearToolsError ? null : toolsError ?? this.toolsError,
        saveError: saveError,
      );

  @override
  List<Object?> get props => [
        settings.serviceUrl,
        settings.accountId,
        settings.apiType,
        settings.mcpEnabled,
        settings.models,
        settings.tools,
        modelsLoading,
        toolsLoading,
        modelsError,
        toolsError,
        saveError
      ];
}
