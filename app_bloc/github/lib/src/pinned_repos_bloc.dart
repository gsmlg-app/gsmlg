import 'package:app_database/app_database.dart';
import 'package:bloc/bloc.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:github_api/github_api.dart';

part 'pinned_repos_event.dart';
part 'pinned_repos_state.dart';

/// BLoC for managing pinned (selected) GitHub repositories.
///
/// Handles loading, adding, and removing repositories from the pinned list.
/// Uses database for persistence and GitHub API for fetching repo details.
class GitHubPinnedReposBloc
    extends Bloc<GitHubPinnedReposEvent, GitHubPinnedReposState> {
  GitHubPinnedReposBloc({required AppDatabase database, required GitHubApi api})
    : _database = database,
      _api = api,
      super(const GitHubPinnedReposInitial()) {
    on<GitHubPinnedReposLoad>(_onLoad);
    on<GitHubPinnedReposAdd>(_onAdd);
    on<GitHubPinnedReposRemove>(_onRemove);
    on<GitHubPinnedReposRefresh>(_onRefresh);
  }

  final AppDatabase _database;
  final GitHubApi _api;

  Future<void> _onLoad(
    GitHubPinnedReposLoad event,
    Emitter<GitHubPinnedReposState> emit,
  ) async {
    emit(const GitHubPinnedReposLoading());

    try {
      final repos = await _database.select(_database.gitHubRepoTable).get();
      emit(GitHubPinnedReposLoaded(repos: repos));
    } catch (e) {
      emit(GitHubPinnedReposError(message: e.toString()));
    }
  }

  Future<void> _onAdd(
    GitHubPinnedReposAdd event,
    Emitter<GitHubPinnedReposState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GitHubPinnedReposLoaded) return;

    try {
      // Fetch repo details from API if we have owner/repo
      Repository? repoDetails;
      if (event.owner != null && event.repoName != null) {
        repoDetails = await _api.repos.getRepo(
          owner: event.owner!,
          repo: event.repoName!,
        );
      }

      // Insert into database
      final companion = GitHubRepoTableCompanion.insert(
        repoId: repoDetails?.id ?? event.repoId ?? 0,
        fullName: repoDetails?.fullName ?? '${event.owner}/${event.repoName}',
        name: repoDetails?.name ?? event.repoName ?? '',
        ownerLogin: repoDetails?.owner.login ?? event.owner ?? '',
        ownerAvatarUrl: Value(repoDetails?.owner.avatarUrl),
        description: Value(repoDetails?.description),
        isPrivate: Value(repoDetails?.private ?? false),
        defaultBranch: Value(repoDetails?.defaultBranch ?? 'main'),
        stargazersCount: Value(repoDetails?.stargazersCount ?? 0),
      );

      await _database
          .into(_database.gitHubRepoTable)
          .insert(companion, mode: InsertMode.insertOrReplace);

      // Reload repos
      final repos = await _database.select(_database.gitHubRepoTable).get();
      emit(GitHubPinnedReposLoaded(repos: repos));
    } catch (e) {
      emit(GitHubPinnedReposError(message: e.toString()));
    }
  }

  Future<void> _onRemove(
    GitHubPinnedReposRemove event,
    Emitter<GitHubPinnedReposState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GitHubPinnedReposLoaded) return;

    try {
      await (_database.delete(
        _database.gitHubRepoTable,
      )..where((t) => t.repoId.equals(event.repoId))).go();

      // Reload repos
      final repos = await _database.select(_database.gitHubRepoTable).get();
      emit(GitHubPinnedReposLoaded(repos: repos));
    } catch (e) {
      emit(GitHubPinnedReposError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
    GitHubPinnedReposRefresh event,
    Emitter<GitHubPinnedReposState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GitHubPinnedReposLoaded) return;

    emit(const GitHubPinnedReposLoading());

    try {
      // Refresh each repo from API and update in database
      for (final repo in currentState.repos) {
        try {
          final repoDetails = await _api.repos.getRepo(
            owner: repo.ownerLogin,
            repo: repo.name,
          );

          await (_database.update(
            _database.gitHubRepoTable,
          )..where((t) => t.repoId.equals(repo.repoId))).write(
            GitHubRepoTableCompanion(
              description: Value(repoDetails.description),
              stargazersCount: Value(repoDetails.stargazersCount ?? 0),
              ownerAvatarUrl: Value(repoDetails.owner.avatarUrl),
              updatedAt: Value(DateTime.now()),
            ),
          );
        } catch (_) {
          // Skip repos that can't be fetched (deleted, permissions changed, etc.)
        }
      }

      // Reload repos
      final repos = await _database.select(_database.gitHubRepoTable).get();
      emit(GitHubPinnedReposLoaded(repos: repos));
    } catch (e) {
      emit(GitHubPinnedReposError(message: e.toString()));
    }
  }

  /// Check if a repo is pinned by its ID.
  bool isPinned(int repoId) {
    final currentState = state;
    if (currentState is! GitHubPinnedReposLoaded) return false;
    return currentState.repos.any((r) => r.repoId == repoId);
  }
}
