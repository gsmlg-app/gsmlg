import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:github_api/github_api.dart';

part 'event.dart';
part 'state.dart';
part 'github_user.dart';

class GitHubBloc extends Bloc<GitHubEvent, GitHubState> {
  GitHubBloc({
    required VaultRepository vault,
    GitHubApi? api,
  })  : _vault = vault,
        _api = api,
        super(const GitHubInitial()) {
    on<GitHubLoad>(_onLoad);
    on<GitHubConnect>(_onConnect);
    on<GitHubDisconnect>(_onDisconnect);
    on<GitHubRefresh>(_onRefresh);
  }

  final VaultRepository _vault;
  GitHubApi? _api;

  static const String _patKey = 'github_pat';

  /// Get the current API instance (if connected).
  GitHubApi? get api => _api;

  Future<void> _onLoad(
    GitHubLoad event,
    Emitter<GitHubState> emit,
  ) async {
    emit(const GitHubLoading());

    try {
      final pat = await _vault.read(key: _patKey);
      if (pat == null || pat.isEmpty) {
        emit(const GitHubDisconnected());
        return;
      }

      _api = GitHubApi(token: pat);
      final userResponse = await _api!.users.getAuthenticatedUser();
      final user = GitHubUser.fromApiResponse(userResponse);
      emit(GitHubConnected(user: user, pat: pat));
    } catch (e) {
      _api = null;
      emit(GitHubError(message: e.toString()));
    }
  }

  Future<void> _onConnect(
    GitHubConnect event,
    Emitter<GitHubState> emit,
  ) async {
    emit(const GitHubLoading());

    try {
      // Validate PAT by fetching user info
      _api = GitHubApi(token: event.pat);
      final userResponse = await _api!.users.getAuthenticatedUser();
      final user = GitHubUser.fromApiResponse(userResponse);

      // Save PAT to secure storage
      await _vault.write(key: _patKey, value: event.pat);

      emit(GitHubConnected(user: user, pat: event.pat));
    } catch (e) {
      _api = null;
      final message = e.toString();
      if (message.contains('401')) {
        emit(const GitHubError(message: 'Invalid Personal Access Token'));
      } else {
        emit(GitHubError(message: 'Failed to connect: $message'));
      }
    }
  }

  Future<void> _onDisconnect(
    GitHubDisconnect event,
    Emitter<GitHubState> emit,
  ) async {
    emit(const GitHubLoading());

    try {
      _api?.close();
      _api = null;
      await _vault.delete(key: _patKey);
      emit(const GitHubDisconnected());
    } catch (e) {
      emit(GitHubError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
    GitHubRefresh event,
    Emitter<GitHubState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GitHubConnected) return;

    emit(const GitHubLoading());

    try {
      if (_api == null) {
        _api = GitHubApi(token: currentState.pat);
      }
      final userResponse = await _api!.users.getAuthenticatedUser();
      final user = GitHubUser.fromApiResponse(userResponse);
      emit(GitHubConnected(user: user, pat: currentState.pat));
    } catch (e) {
      emit(GitHubError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _api?.close();
    return super.close();
  }
}
