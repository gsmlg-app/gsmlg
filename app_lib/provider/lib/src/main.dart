import 'terminal_dependencies_stub.dart'
    if (dart.library.io) 'terminal_dependencies_native.dart';
import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_audio/audio.dart';
import 'package:app_agent/app_agent.dart';
import 'dart:convert';
import 'dart:isolate' show SendPort;
import 'package:app_database/app_database.dart';
import 'package:app_duckdb/app_duckdb.dart' show LogStore;
import 'package:app_editor/app_editor.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:audio_bloc/audio_bloc.dart';
import 'package:auth_bloc/auth_bloc.dart';
import 'package:bluetooth_bloc/bluetooth_bloc.dart';
import 'package:camera_bloc/camera_bloc.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:domain_bloc/domain_bloc.dart';
import 'package:editor_bloc/editor_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_bloc/github_bloc.dart';
import 'package:isolate_orchestrator/isolate_orchestrator.dart' show IsolateHub;
import 'package:navigation_bloc/navigation_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_bloc/theme_bloc.dart';
import 'package:tts_dataset/tts_dataset.dart';
import 'package:tts_dataset_bloc/tts_dataset_bloc.dart';
import 'package:vultr_bloc/vultr_bloc.dart';
import 'package:whois_bloc/whois_bloc.dart';
import 'package:monitor_bloc/monitor_bloc.dart';
import 'package:log_viewer_bloc/log_viewer_bloc.dart';
import 'package:whois_history_bloc/whois_history_bloc.dart';

class MainProvider extends StatelessWidget {
  const MainProvider({
    super.key,
    required this.child,
    required this.sharedPrefs,
    required this.database,
    required this.vault,
    required this.hub,
    required this.logStore,
    this.logIngest,
    this.logIngestChanges,
  });

  final Widget child;
  final SharedPreferences sharedPrefs;
  final AppDatabase database;
  final VaultRepository vault;

  /// The app's isolate hub (runs the `logstore` worker).
  final IsolateHub hub;

  /// Log store read by the Log Center (backed by the `logstore` isolate).
  final LogStore logStore;

  /// Current log store ingest port (null: agent isolates drop their logs).
  final SendPort? Function()? logIngest;

  /// New ingest ports after a log store restart; agent isolates follow them.
  final Stream<SendPort?>? logIngestChanges;

  /// Remote MCP profiles (JSON) for tools, read fresh on every use.
  List<String> _remoteMcpProfiles() {
    final profiles =
        sharedPrefs.getStringList('remote_mcp_profiles') ?? const <String>[];
    final managed = BackplaneSettingsBloc.readSettings(sharedPrefs).mcpProfile;
    return [...profiles, if (managed != null) jsonEncode(managed)];
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        ...terminalRepositories(database),
        RepositoryProvider<EditorFileService>(
          create: (context) => EditorFileService(),
          dispose: (files) => files.dispose(),
        ),
        RepositoryProvider<SharedPreferences>(create: (context) => sharedPrefs),
        RepositoryProvider<AppDatabase>(create: (context) => database),
        RepositoryProvider<IsolateHub>.value(value: hub),
        RepositoryProvider<LogStore>.value(value: logStore),
        RepositoryProvider<VaultRepository>(create: (context) => vault),
        RepositoryProvider<GemmaRepository>(
          create: (context) => GemmaRepository(),
        ),
        RepositoryProvider<LocalModelAccess>(
          create: (context) =>
              LocalModelAccess.forResource(context.read<GemmaRepository>()),
        ),
        RepositoryProvider<RemoteLlmRepository>(
          create: (context) =>
              RemoteLlmRepository(secrets: VaultSecretReader(vault)),
        ),
        RepositoryProvider<BackplaneServiceRepository>(
          create: (context) => BackplaneServiceRepository(
            data: DatabaseToolDataSource(database),
            secrets: VaultSecretReader(vault),
            remoteLlm: context.read<RemoteLlmRepository>(),
          ),
        ),
        RepositoryProvider<ChatStorageRepository>(
          create: (context) => ChatStorageRepository(database),
        ),
        RepositoryProvider<AgentRepository>(
          create: (context) => AgentRepository(database),
        ),
        RepositoryProvider<TtsDatasetRepository>(
          create: (context) => TtsDatasetRepository(database),
        ),
        RepositoryProvider<OpenAiAudioRepository>(
          create: (context) =>
              OpenAiAudioRepository(database: database, vault: vault),
        ),
        RepositoryProvider<ToolExecutor>(
          create: (context) => ToolExecutor(
            data: DatabaseToolDataSource(database),
            secrets: VaultSecretReader(vault),
            remoteMcpProfilesProvider: _remoteMcpProfiles,
          ),
        ),
        RepositoryProvider<AgentServicesServer>(
          create: (context) => AgentServicesServer(
            secrets: VaultSecretReader(vault),
            data: DatabaseToolDataSource(database),
            // No lease here: ChatBloc holds the FIFO LocalModelAccess lease
            // for the whole local run, so leasing per generation would
            // deadlock.
            localLlm: GemmaLocalLlmGateway(context.read<GemmaRepository>()),
          ),
          dispose: (services) => services.close(),
        ),
        // Every agent runs in its own `agent:<id>` isolate; there is no
        // in-process fallback.
        RepositoryProvider<AgentHost>(
          create: (context) => AgentHost(
            hub: hub,
            services: context.read<AgentServicesServer>(),
            logIngest: logIngest?.call(),
            logIngestChanges: logIngestChanges,
            loadDefinition: context.read<AgentRepository>().get,
            secrets: VaultSecretReader(vault),
            mcpProfiles: _remoteMcpProfiles,
          ),
          dispose: (host) => host.dispose(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          ...terminalBlocs(database),
          BlocProvider<EditorCubit>(
            create: (context) => EditorCubit(context.read<EditorFileService>()),
          ),
          BlocProvider<NavigationBloc>(create: (context) => NavigationBloc()),
          BlocProvider<DmThemeBloc>(
            create: (context) => DmThemeBloc(prefs: sharedPrefs),
          ),
          BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
          BlocProvider<WhoisBloc>(create: (context) => WhoisBloc(database)),
          BlocProvider<WhoisHistoryBloc>(
            create: (context) => WhoisHistoryBloc(database),
          ),
          BlocProvider<BluetoothBloc>(create: (context) => BluetoothBloc()),
          BlocProvider<CameraBloc>(create: (context) => CameraBloc()),
          BlocProvider<ZoneBloc>(create: (context) => ZoneBloc(database)),
          BlocProvider<RecordBloc>(create: (context) => RecordBloc(vault)),
          BlocProvider<GitHubBloc>(
            create: (context) =>
                GitHubBloc(vault: vault)..add(const GitHubLoad()),
          ),
          BlocProvider<VultrBloc>(
            create: (context) => VultrBloc(vault: vault, database: database),
          ),
          BlocProvider<AccountsBloc>(
            create: (context) =>
                AccountsBloc(database: database, vault: vault)
                  ..add(const AccountsLoad()),
          ),
          BlocProvider<ChatSettingsBloc>(
            create: (context) => ChatSettingsBloc(
              repository: context.read<ChatStorageRepository>(),
              preferences: context.read<SharedPreferences>(),
              agentRepository: context.read<AgentRepository>(),
            ),
          ),
          BlocProvider<BackplaneSettingsBloc>(
            create: (context) => BackplaneSettingsBloc(
              preferences: sharedPrefs,
              service: context.read<BackplaneServiceRepository>(),
            ),
          ),
          BlocProvider<GemmaModelBloc>(
            create: (context) => GemmaModelBloc(
              repository: context.read<GemmaRepository>(),
              preferences: context.read<SharedPreferences>(),
              modelAccess: context.read<LocalModelAccess>(),
            ),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
              titleGenerator: EmbeddedConversationTitleGenerator(
                MiniCpmTitleBackend(),
              ),
              gemmaRepository: context.read<GemmaRepository>(),
              modelAccess: context.read<LocalModelAccess>(),
              remoteRepository: context.read<RemoteLlmRepository>(),
              storageRepository: context.read<ChatStorageRepository>(),
              toolExecutor: context.read<ToolExecutor>(),
              agentRepository: context.read<AgentRepository>(),
              agentRunner: context.read<AgentHost>(),
              preferences: sharedPrefs,
              backplaneService: context.read<BackplaneServiceRepository>(),
            ),
          ),
          BlocProvider<MonitorBloc>(
            create: (context) => MonitorBloc(
              repository: MonitorRepository(),
              trustStore: DbTrustStore(database),
            ),
          ),
          BlocProvider<TtsDatasetBloc>(
            create: (context) => TtsDatasetBloc(
              repository: context.read<TtsDatasetRepository>(),
            ),
          ),
          BlocProvider<AudioSettingsBloc>(
            create: (context) =>
                AudioSettingsBloc(preferences: sharedPrefs)
                  ..add(const AudioSettingsLoad()),
          ),
          BlocProvider<AudioServiceBloc>(
            create: (context) => AudioServiceBloc(
              repository: context.read<OpenAiAudioRepository>(),
              settingsProvider: () =>
                  context.read<AudioSettingsBloc>().state.settings,
            ),
          ),
          BlocProvider<LogFileBloc>(create: (context) => LogFileBloc()),
          BlocProvider<FilterBloc>(create: (context) => FilterBloc()),
          BlocProvider<SelectionBloc>(create: (context) => SelectionBloc()),
        ],
        child: child,
      ),
    );
  }
}
