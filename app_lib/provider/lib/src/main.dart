import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_chat/app_chat.dart';
import 'dart:convert';
import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:auth_bloc/auth_bloc.dart';
import 'package:bluetooth_bloc/bluetooth_bloc.dart';
import 'package:camera_bloc/camera_bloc.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:domain_bloc/domain_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_bloc/github_bloc.dart';
import 'package:navigation_bloc/navigation_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_bloc/theme_bloc.dart';
import 'package:tts_dataset/tts_dataset.dart';
import 'package:tts_dataset_bloc/tts_dataset_bloc.dart';
import 'package:vultr_bloc/vultr_bloc.dart';
import 'package:whois_bloc/whois_bloc.dart';
import 'package:monitor_bloc/monitor_bloc.dart';
import 'package:whois_history_bloc/whois_history_bloc.dart';

class MainProvider extends StatelessWidget {
  const MainProvider({
    super.key,
    required this.child,
    required this.sharedPrefs,
    required this.database,
    required this.vault,
  });

  final Widget child;
  final SharedPreferences sharedPrefs;
  final AppDatabase database;
  final VaultRepository vault;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SharedPreferences>(create: (context) => sharedPrefs),
        RepositoryProvider<AppDatabase>(create: (context) => database),
        RepositoryProvider<VaultRepository>(create: (context) => vault),
        RepositoryProvider<GemmaRepository>(
          create: (context) => GemmaRepository(),
        ),
        RepositoryProvider<RemoteLlmRepository>(
          create: (context) => RemoteLlmRepository(vault: vault),
        ),
        RepositoryProvider<BackplaneServiceRepository>(
          create: (context) => BackplaneServiceRepository(
            database: database,
            vault: vault,
            remoteLlm: context.read<RemoteLlmRepository>(),
          ),
        ),
        RepositoryProvider<ChatStorageRepository>(
          create: (context) => ChatStorageRepository(database),
        ),
        RepositoryProvider<TtsDatasetRepository>(
          create: (context) => TtsDatasetRepository(database),
        ),
        RepositoryProvider<ToolExecutor>(
          create: (context) => ToolExecutor(
            database: database,
            vault: vault,
            remoteMcpProfilesProvider: () {
              final profiles =
                  sharedPrefs.getStringList('remote_mcp_profiles') ??
                  const <String>[];
              final managed = BackplaneSettingsBloc.readSettings(
                sharedPrefs,
              ).mcpProfile;
              return [...profiles, if (managed != null) jsonEncode(managed)];
            },
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
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
            ),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
              gemmaRepository: context.read<GemmaRepository>(),
              remoteRepository: context.read<RemoteLlmRepository>(),
              storageRepository: context.read<ChatStorageRepository>(),
              toolExecutor: context.read<ToolExecutor>(),
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
        ],
        child: child,
      ),
    );
  }
}
