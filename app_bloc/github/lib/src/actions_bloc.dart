import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:github_api/github_api.dart';
import 'package:yaml/yaml.dart';

import 'models.dart';

part 'actions_event.dart';
part 'actions_state.dart';

class GitHubActionsBloc extends Bloc<GitHubActionsEvent, GitHubActionsState> {
  GitHubActionsBloc({
    required GitHubApi api,
    required String owner,
    required String repo,
  }) : _api = api,
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
      final workflows = await Future.wait(
        workflowsResponse.workflows
            .map(GitHubWorkflow.fromApiResponse)
            .map(_loadWorkflowInputs),
      );

      final runsResponse = await _api.actions.listWorkflowRuns(
        owner: _owner,
        repo: _repo,
        perPage: 30,
      );
      final runs = runsResponse.workflowRuns
          .map(GitHubWorkflowRun.fromApiResponse)
          .toList();

      emit(GitHubActionsLoaded(workflows: workflows, runs: runs));
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

  Future<GitHubWorkflow> _loadWorkflowInputs(GitHubWorkflow workflow) async {
    try {
      final content = await _api.repos.getRepositoryContent(
        owner: _owner,
        repo: _repo,
        path: workflow.path,
      );
      final workflowYaml = _decodeRepositoryContent(content);
      if (workflowYaml == null) return workflow;

      return workflow.copyWith(
        inputs: _parseWorkflowDispatchInputs(workflowYaml),
      );
    } catch (_) {
      return workflow;
    }
  }

  String? _decodeRepositoryContent(RepositoryContent content) {
    if (content.encoding != 'base64' || content.content == null) return null;

    final normalized = content.content!.replaceAll(RegExp(r'\s'), '');
    return utf8.decode(base64.decode(normalized));
  }

  List<GitHubWorkflowInput> _parseWorkflowDispatchInputs(String workflowYaml) {
    try {
      final document = loadYaml(workflowYaml);
      if (document is! YamlMap) return const [];

      final triggers =
          _yamlMapValue(document, 'on') ?? _yamlMapValue(document, true);
      if (triggers is! YamlMap) return const [];

      final dispatch = _yamlMapValue(triggers, 'workflow_dispatch');
      if (dispatch is! YamlMap) return const [];

      final inputs = _yamlMapValue(dispatch, 'inputs');
      if (inputs is! YamlMap) return const [];

      return [
        for (final entry in inputs.nodes.entries)
          if (_yamlKey(entry.key).isNotEmpty)
            _workflowInputFromYaml(_yamlKey(entry.key), entry.value.value),
      ];
    } catch (_) {
      return const [];
    }
  }

  Object? _yamlMapValue(YamlMap map, Object key) {
    if (map.containsKey(key)) return map[key];
    return null;
  }

  GitHubWorkflowInput _workflowInputFromYaml(String name, Object? value) {
    if (value is! YamlMap) {
      return GitHubWorkflowInput(name: name);
    }

    return GitHubWorkflowInput(
      name: name,
      description: _yamlString(_yamlMapValue(value, 'description')),
      defaultValue: _yamlString(_yamlMapValue(value, 'default')),
      required: _yamlBool(_yamlMapValue(value, 'required')) ?? false,
      type: _yamlString(_yamlMapValue(value, 'type')),
      options: _yamlStringList(_yamlMapValue(value, 'options')),
    );
  }

  String _yamlKey(YamlNode node) {
    final value = node.value;
    return value == null ? '' : value.toString();
  }

  String? _yamlString(Object? value) {
    if (value == null) return null;
    return value.toString();
  }

  bool? _yamlBool(Object? value) {
    if (value is bool) return value;
    if (value is String) return bool.tryParse(value);
    return null;
  }

  List<String> _yamlStringList(Object? value) {
    if (value is! YamlList) return const [];

    return [
      for (final option in value)
        if (option != null) option.toString(),
    ];
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
        body: WorkflowDispatchRequest(ref: event.ref, inputs: event.inputs),
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
