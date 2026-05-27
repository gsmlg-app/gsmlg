import 'dart:io';

import 'package:app_database/app_database.dart';
import 'package:app_locale/app_locale.dart';
import 'package:app_logging/app_logging.dart';
import 'package:app_provider/app_provider.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  Directory? applicationSupportDirectory;
  File? bootstrapLogFile;

  try {
    applicationSupportDirectory = await getApplicationSupportDirectory();
    bootstrapLogFile = await _bootstrapLogFile(applicationSupportDirectory);
    await _appendBootstrapLog(
      bootstrapLogFile,
      'bootstrap: support directory ready',
    );

    // Initialize logging
    final logger = AppLogger();
    logger.initialize(level: LogLevel.debug);
    logger.logStream.listen((record) {
      final log =
          '${record.loggerName} ${record.level.name} [${record.time}]: ${record.message}';
      bootstrapLogFile!.writeAsString('$log\n', mode: FileMode.append);
    });
    logger.i('App started');

    final sharedPrefs = await SharedPreferences.getInstance();
    logger.i('SharedPreferences initialized');
    final database = AppDatabase();
    logger.i('Database initialized');
    final vault = SecureStorageVaultRepository(namespace: 'gsmlg');
    logger.i('Vault initialized');

    runApp(
      MainProvider(
        sharedPrefs: sharedPrefs,
        database: database,
        vault: vault,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: CrashReportingWidget(child: const App()),
        ),
      ),
    );
    logger.i('runApp called');
  } catch (error, stackTrace) {
    await _appendBootstrapLog(
      bootstrapLogFile,
      'bootstrap failed',
      error: error,
      stackTrace: stackTrace,
    );
    runApp(BootstrapErrorApp(error: error, stackTrace: stackTrace));
  }
}

Future<File> _bootstrapLogFile(Directory applicationSupportDirectory) async {
  final directory = Directory(
    path.join(applicationSupportDirectory.path, 'gsmlg'),
  );
  await directory.create(recursive: true);
  return File(path.join(directory.path, 'app.log'));
}

Future<void> _appendBootstrapLog(
  File? file,
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) async {
  final buffer = StringBuffer()
    ..write(DateTime.now().toIso8601String())
    ..write(' ')
    ..write(message);
  if (error != null) {
    buffer
      ..write('\n')
      ..write(error);
  }
  if (stackTrace != null) {
    buffer
      ..write('\n')
      ..write(stackTrace);
  }

  final line = buffer.toString();
  debugPrint(line);
  if (file != null) {
    await file.writeAsString('$line\n', mode: FileMode.append);
  }
}

class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({
    super.key,
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GSMLG failed to start',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                SelectableText(error.toString()),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      stackTrace.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
