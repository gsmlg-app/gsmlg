import 'package:accounts_bloc/accounts_bloc.dart';
import 'package:app_chat/app_chat.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_bloc/theme_bloc.dart';
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
        RepositoryProvider<ChatStorageRepository>(
          create: (context) => ChatStorageRepository(database),
        ),
        RepositoryProvider<ToolExecutor>(
          create: (context) => ToolExecutor(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(create: (context) => ThemeBloc(sharedPrefs)),
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
            ),
          ),
          BlocProvider<GemmaModelBloc>(
            create: (context) => GemmaModelBloc(
              repository: context.read<GemmaRepository>(),
              preferences: context.read<SharedPreferences>(),
              toolExecutor: context.read<ToolExecutor>(),
            ),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
              gemmaRepository: context.read<GemmaRepository>(),
              storageRepository: context.read<ChatStorageRepository>(),
              toolExecutor: context.read<ToolExecutor>(),
            ),
          ),
          BlocProvider<MonitorBloc>(
            create: (context) => MonitorBloc(
              repository: MonitorRepository(),
              trustStore: DbTrustStore(database),
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
