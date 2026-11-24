import 'package:app_database/app_database.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vnc_host_bloc/vnc_host_bloc.dart';

List<BlocProvider<dynamic>> vncBlocs(
  AppDatabase database,
  VaultRepository vault,
) => [
  BlocProvider<VncHostBloc>(
    create: (context) => VncHostBloc(
      repository: VncHostRepository(database: database, vault: vault),
    )..add(const VncHostLoad()),
  ),
];
