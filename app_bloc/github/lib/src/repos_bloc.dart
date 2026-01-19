import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:github_api/github_api.dart';

import 'models.dart';

part 'repos_event.dart';
part 'repos_state.dart';

class GitHubReposBloc extends Bloc<GitHubReposEvent, GitHubReposState> {
  GitHubReposBloc({
    required GitHubApi api,
  })  : _api = api,
        super(const GitHubReposInitial()) {
    on<GitHubReposFetch>(_onFetch);
    on<GitHubReposFetchOrgs>(_onFetchOrgs);
    on<GitHubReposFetchOrgRepos>(_onFetchOrgRepos);
    on<GitHubReposRefresh>(_onRefresh);
  }

  final GitHubApi _api;

  Future<void> _onFetch(
    GitHubReposFetch event,
    Emitter<GitHubReposState> emit,
  ) async {
    emit(const GitHubReposLoading());

    try {
      // Fetch user repos
      final userRepoResponses = await _fetchAllUserRepos();
      final userRepos = userRepoResponses.map(GitHubRepo.fromApiResponse).toList();

      // Fetch organizations
      final orgResponses = await _api.users.listOrgsForAuthenticatedUser();
      final orgs = orgResponses.map(GitHubOrg.fromApiResponse).toList();

      emit(GitHubReposLoaded(
        userRepos: userRepos,
        orgs: orgs,
        orgRepos: const {},
      ));
    } catch (e) {
      emit(GitHubReposError(message: e.toString()));
    }
  }

  Future<void> _onFetchOrgs(
    GitHubReposFetchOrgs event,
    Emitter<GitHubReposState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GitHubReposLoaded) return;

    try {
      final orgResponses = await _api.users.listOrgsForAuthenticatedUser();
      final orgs = orgResponses.map(GitHubOrg.fromApiResponse).toList();
      emit(currentState.copyWith(orgs: orgs));
    } catch (e) {
      emit(GitHubReposError(message: e.toString()));
    }
  }

  Future<void> _onFetchOrgRepos(
    GitHubReposFetchOrgRepos event,
    Emitter<GitHubReposState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GitHubReposLoaded) return;

    try {
      final repoResponses = await _fetchAllOrgRepos(event.orgLogin);
      final repos = repoResponses.map(GitHubRepo.fromApiResponse).toList();
      final updatedOrgRepos = Map<String, List<GitHubRepo>>.from(currentState.orgRepos);
      updatedOrgRepos[event.orgLogin] = repos;
      emit(currentState.copyWith(orgRepos: updatedOrgRepos));
    } catch (e) {
      emit(GitHubReposError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
    GitHubReposRefresh event,
    Emitter<GitHubReposState> emit,
  ) async {
    add(const GitHubReposFetch());
  }

  Future<List<Repository>> _fetchAllUserRepos() async {
    final repos = <Repository>[];
    int page = 1;
    const perPage = 100;

    while (true) {
      final response = await _api.repos.listReposForAuthenticatedUser(
        perPage: perPage,
        page: page,
        sort: Sort.updated,
        affiliation: 'owner,collaborator',
      );

      if (response.isEmpty) break;
      repos.addAll(response);
      if (response.length < perPage) break;
      page++;
    }

    return repos;
  }

  Future<List<Repository>> _fetchAllOrgRepos(String orgLogin) async {
    final repos = <Repository>[];
    int page = 1;
    const perPage = 100;

    while (true) {
      final response = await _api.orgs.listOrgRepos(
        org: orgLogin,
        perPage: perPage,
        page: page,
        sort: Sort.updated,
      );

      if (response.isEmpty) break;
      repos.addAll(response);
      if (response.length < perPage) break;
      page++;
    }

    return repos;
  }
}
