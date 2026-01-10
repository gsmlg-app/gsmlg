import 'dart:io';

import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_logging/app_logging.dart';
import 'package:app_provider/app_provider.dart';
import 'package:auth_bloc/auth_bloc.dart';
import 'package:bluetooth_bloc/bluetooth_bloc.dart';
import 'package:camera_bloc/camera_bloc.dart';
import 'package:domain_bloc/domain_bloc.dart';
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

  runApp(
    MainProvider(
      sharedPrefs: sharedPrefs,
      database: database,
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
            create: (context) => ZoneBloc(database),
          ),
          BlocProvider<RecordBloc>(
            create: (context) => RecordBloc(),
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
