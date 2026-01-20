import 'dart:io';

import 'package:app_chat/app_chat.dart';
import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_logging/app_logging.dart';
import 'package:app_provider/app_provider.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:auth_bloc/auth_bloc.dart';
import 'package:bluetooth_bloc/bluetooth_bloc.dart';
import 'package:camera_bloc/camera_bloc.dart';
import 'package:chat_bloc/chat_bloc.dart';
import 'package:domain_bloc/domain_bloc.dart';
import 'package:github_bloc/github_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_bloc/theme_bloc.dart';
import 'package:whois_bloc/whois_bloc.dart';
import 'package:whois_history_bloc/whois_history_bloc.dart';

import 'app.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final applicationSupportDirectory = await getApplicationSupportDirectory();

  // Initialize logging
  final logger = AppLogger();
  logger.initialize(level: LogLevel.debug);
  final directory = Directory(
    path.join(applicationSupportDirectory.path, 'gsmlg'),
  );
  await directory.create(recursive: true);
  final logFile = File(
    path.join(applicationSupportDirectory.path, 'gsmlg', 'app.log'),
  );
  logger.logStream.listen((record) {
    final log =
        '${record.loggerName} ${record.level.name} [${record.time}]: ${record.message}';
    logFile.writeAsString(log, mode: FileMode.append);
  });
  // Use logger
  logger.i('App started');

  final sharedPrefs = await SharedPreferences.getInstance();
  final database = AppDatabase();

  // Initialize secure storage for API credentials
  final vault = SecureStorageVaultRepository(namespace: 'gsmlg');
  final credentialsService = CredentialsService(vault);

  runApp(
    MainProvider(
      sharedPrefs: sharedPrefs,
      database: database,
      vault: vault,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(sharedPrefs),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(),
          ),
          BlocProvider<WhoisBloc>(
            create: (context) => WhoisBloc(database),
          ),
          BlocProvider<WhoisHistoryBloc>(
            create: (context) => WhoisHistoryBloc(database),
          ),
          BlocProvider<BluetoothBloc>(
            create: (context) => BluetoothBloc(),
          ),
          BlocProvider<CameraBloc>(
            create: (context) => CameraBloc(),
          ),
          BlocProvider<ZoneBloc>(
            create: (context) => ZoneBloc(database, credentialsService),
          ),
          BlocProvider<RecordBloc>(
            create: (context) => RecordBloc(credentialsService),
          ),
          BlocProvider<GitHubBloc>(
            create: (context) => GitHubBloc(vault: vault)..add(const GitHubLoad()),
          ),
          // Chat BLoCs - create repositories and inject into BLoCs
          RepositoryProvider<GemmaRepository>(
            create: (context) => GemmaRepository(),
          ),
          RepositoryProvider<ChatStorageRepository>(
            create: (context) => ChatStorageRepository(database),
          ),
          BlocProvider<ChatSettingsBloc>(
            create: (context) => ChatSettingsBloc(
              repository: context.read<ChatStorageRepository>(),
            ),
          ),
          BlocProvider<GemmaModelBloc>(
            create: (context) => GemmaModelBloc(
              repository: context.read<GemmaRepository>(),
            ),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => ChatBloc(
              gemmaRepository: context.read<GemmaRepository>(),
              storageRepository: context.read<ChatStorageRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: CrashReportingWidget(child: const App()),
        ),
      ),
    ),
  );
}
