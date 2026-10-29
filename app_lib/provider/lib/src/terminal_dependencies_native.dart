import 'package:app_database/app_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:shell_profile_bloc/shell_profile_bloc.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:ssh_key_bloc/ssh_key_bloc.dart';
import 'package:terminal_hosts/terminal_hosts.dart';
import 'package:terminal_tab_bloc/terminal_tab_bloc.dart';
import 'package:terminal_settings_bloc/terminal_settings_bloc.dart';
import 'terminal_session_bloc.dart';

List<RepositoryProvider<dynamic>> terminalRepositories(AppDatabase database) =>
    [
      RepositoryProvider<SshCredentialRepository>(
        create: (context) => SshCredentialRepository(
          database,
          vault: SecureStorageVaultRepository(namespace: 'gsmlg-terminal-ssh'),
        ),
      ),
      RepositoryProvider<SshHostKeyStore>(
        create: (context) => SshHostKeyStore(
          vault: SecureStorageVaultRepository(
            namespace: 'gsmlg-terminal-host-keys',
          ),
        ),
      ),
    ];

List<BlocProvider<dynamic>> terminalBlocs(AppDatabase database) => [
  BlocProvider<SshKeyBloc>(
    create: (context) => SshKeyBloc(
      database,
      credentials: context.read<SshCredentialRepository>(),
    )..add(SshKeyLoad()),
  ),
  BlocProvider<SshKeyFormBloc>(
    create: (context) => SshKeyFormBloc(context.read<SshKeyBloc>()),
  ),
  BlocProvider<SshHostBloc>(
    create: (context) => SshHostBloc(
      database,
      credentials: context.read<SshCredentialRepository>(),
    )..add(SshHostLoad()),
  ),
  BlocProvider<SshHostFormBloc>(
    create: (context) => SshHostFormBloc(context.read<SshHostBloc>()),
  ),
  BlocProvider<TerminalTabBloc>(create: (context) => TerminalSessionBloc()),
  BlocProvider<TerminalSettingsBloc>(
    create: (context) => TerminalSettingsBloc(
      vault: SecureStorageVaultRepository(namespace: 'gsmlg-terminal'),
    )..add(const TerminalSettingsLoad()),
  ),
  BlocProvider<ShellProfileBloc>(
    create: (context) => ShellProfileBloc(database)
      ..add(const EnsureDefaultProfile())
      ..add(const LoadShellProfiles()),
  ),
];
