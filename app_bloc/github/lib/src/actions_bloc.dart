import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:github_api/github_api.dart';

import 'models.dart';

part 'actions_event.dart';
part 'actions_state.dart';

class GitHubActionsBloc extends Bloc<GitHubActionsEvent, GitHubActionsState> {
  GitHubActionsBloc({
    required GitHubApi api,
    required String owner,
    required String repo,
  })  : _api = api,
        _owner = owner,
        _repo = repo,
        super(const GitHubActionsInitial()) {
    on<GitHubActionsFetch>(_onFetch);
    on<GitHubActionsFetchRuns>(_onFetchRuns);
    on<GitHubActionsDispatch>(_onDispatch);
    on<GitHubActionsRefresh>(_onRefresh);
    on<GitHubActionsRerun>(_onRerun);
    on<GitHubActionsCancel>(_onCancel);
  }

  final GitHubApi _api;
  final String _owner;
  final String _repo;

  Future<void> _onFetch(
    GitHubActionsFetch event,
    Emitter<GitHubActionsState> emit,
  ) async {
    emit(const GitHubActionsLoading());

    try {
      final workflowsResponse = await _api.actions.listWorkflows(
        owner: _owner,
        repo: _repo,
      );
      final workflows = workflowsResponse.workflows
          .map(GitHubWorkflow.fromApiResponse)
          .toList();

      final runsResponse = await _api.actions.listWorkflowRuns(
        owner: _owner,
        repo: _repo,
        perPage: 30,
      );
      final runs = runsResponse.workflowRuns
          .map(GitHubWorkflowRun.fromApiResponse)
          .toList();

      emit(GitHubActionsLoaded(
        workflows: workflows,
        runs: runs,
      ));
    } catch (e) {
      emit(GitHubActionsError(message: e.toString()));
    }
  }

  Future<void> _onFetchRuns(
    GitHubActionsFetchRuns event,
    Emitter<GitHubActionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GitHubActionsLoaded) return;

    try {
      final runsResponse = await _api.actions.listWorkflowRunsForWorkflow(
        owner: _owner,
        repo: _repo,
        workflowId: event.workflowId.toString(),
        perPage: 30,
      );
      final runs = runsResponse.workflowRuns
          .map(GitHubWorkflowRun.fromApiResponse)
          .toList();
      emit(currentState.copyWith(runs: runs));
    } catch (e) {
      emit(GitHubActionsError(message: e.toString()));
    }
  }

  Future<void> _onDispatch(
    GitHubActionsDispatch event,
    Emitter<GitHubActionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GitHubActionsLoaded) return;

    emit(currentState.copyWith(isDispatching: true));

    try {
      await _api.actions.createWorkflowDispatch(
        owner: _owner,
        repo: _repo,
        workflowId: event.workflowId.toString(),
        body: WorkflowDispatchRequest(
          ref: event.ref,
          inputs: event.inputs,
        ),
      );

      // Wait a bit and refresh runs
      await Future.delayed(const Duration(seconds: 2));
      final runsResponse = await _api.actions.listWorkflowRuns(
        owner: _owner,
        repo: _repo,
        perPage: 30,
      );
      final runs = runsResponse.workflowRuns
          .map(GitHubWorkflowRun.fromApiResponse)
          .toList();
      emit(currentState.copyWith(runs: runs, isDispatching: false));
    } catch (e) {
      emit(GitHubActionsError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
    GitHubActionsRefresh event,
    Emitter<GitHubActionsState> emit,
  ) async {
    add(const GitHubActionsFetch());
  }

  Future<void> _onRerun(
    GitHubActionsRerun event,
    Emitter<GitHubActionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GitHubActionsLoaded) return;

    try {
      await _api.actions.rerunWorkflow(
        owner: _owner,
        repo: _repo,
        runId: event.runId,
      );

      // Refresh runs
      await Future.delayed(const Duration(seconds: 1));
      final runsResponse = await _api.actions.listWorkflowRuns(
        owner: _owner,
        repo: _repo,
        perPage: 30,
      );
      final runs = runsResponse.workflowRuns
          .map(GitHubWorkflowRun.fromApiResponse)
          .toList();
      emit(currentState.copyWith(runs: runs));
    } catch (e) {
      emit(GitHubActionsError(message: e.toString()));
    }
  }

  Future<void> _onCancel(
    GitHubActionsCancel event,
    Emitter<GitHubActionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GitHubActionsLoaded) return;

    try {
      await _api.actions.cancelWorkflowRun(
        owner: _owner,
        repo: _repo,
        runId: event.runId,
      );

      // Refresh runs
      await Future.delayed(const Duration(seconds: 1));
      final runsResponse = await _api.actions.listWorkflowRuns(
        owner: _owner,
        repo: _repo,
        perPage: 30,
      );
      final runs = runsResponse.workflowRuns
          .map(GitHubWorkflowRun.fromApiResponse)
          .toList();
      emit(currentState.copyWith(runs: runs));
    } catch (e) {
      emit(GitHubActionsError(message: e.toString()));
    }
  }
}
