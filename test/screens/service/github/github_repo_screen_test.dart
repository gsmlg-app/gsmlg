import 'dart:convert';

import 'package:app_locale/app_locale.dart';
import 'package:app_secure_storage/app_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_api/github_api.dart' as github_api;
import 'package:github_bloc/github_bloc.dart';
import 'package:gsmlg/screens/service/github/github_repo_screen.dart';

void main() {
  testWidgets('opens workflow dispatch dialog with choice inputs', (
    tester,
  ) async {
    const workflowPath = '.github/workflows/release.yml';
    final api = _FakeGitHubApi(
      workflows: [
        const github_api.Workflow(
          id: 1,
          name: 'Release',
          path: workflowPath,
          state: github_api.WorkflowState.active,
        ),
      ],
      contents: {
        workflowPath: _repositoryContent(workflowPath, '''
on:
  workflow_dispatch:
    inputs:
      version:
        description: Release version
        required: true
        type: choice
        options:
          - patch
          - minor
'''),
      },
    );
    final githubBloc = _ConnectedGitHubBloc(api);
    addTearDown(githubBloc.close);

    await tester.pumpWidget(
      BlocProvider<GitHubBloc>.value(
        value: githubBloc,
        child: MaterialApp(
          localizationsDelegates: AppLocale.localizationsDelegates,
          supportedLocales: AppLocale.supportedLocales,
          home: const DmPlatformOverride(
            style: DmPlatformStyle.cupertino,
            child: GitHubRepoScreen(owner: 'gsmlg-app', repo: 'gsmlg'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Run'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });
}

github_api.RepositoryContent _repositoryContent(String path, String content) {
  return github_api.RepositoryContent(
    type: 'file',
    name: path.split('/').last,
    path: path,
    sha: 'sha',
    encoding: 'base64',
    content: base64.encode(utf8.encode(content)),
  );
}

class _ConnectedGitHubBloc extends GitHubBloc {
  _ConnectedGitHubBloc(github_api.GitHubApi api)
    : super(vault: _MemoryVaultRepository(), api: api) {
    emit(
      const GitHubConnected(
        user: GitHubUser(id: 1, login: 'gsmlg'),
        pat: 'test-token',
      ),
    );
  }
}

class _MemoryVaultRepository extends VaultRepository {
  final _values = <String, String>{};

  @override
  Future<bool> containsKey({required String key}) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }

  @override
  Future<String?> read({required String key}) async {
    return _values[key];
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.unmodifiable(_values);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }
}

class _FakeGitHubApi extends github_api.GitHubApi {
  _FakeGitHubApi({
    required List<github_api.Workflow> workflows,
    required Map<String, github_api.RepositoryContent> contents,
  }) : actionsClient = _FakeActionsClient(workflows),
       reposClient = _FakeReposClient(contents),
       super(Dio());

  final _FakeActionsClient actionsClient;
  final _FakeReposClient reposClient;

  @override
  github_api.ActionsClient get actions => actionsClient;

  @override
  github_api.ReposClient get repos => reposClient;
}

class _FakeActionsClient implements github_api.ActionsClient {
  const _FakeActionsClient(this.workflows);

  final List<github_api.Workflow> workflows;

  @override
  Future<github_api.ListWorkflowsResponse> listWorkflows({
    required String owner,
    required String repo,
    int? perPage = 30,
    int? page = 1,
  }) async {
    return github_api.ListWorkflowsResponse(
      totalCount: workflows.length,
      workflows: workflows,
    );
  }

  @override
  Future<github_api.ListWorkflowRunsResponse> listWorkflowRuns({
    required String owner,
    required String repo,
    int? perPage = 30,
    int? page = 1,
    bool? excludePullRequests = false,
    String? actor,
    String? branch,
    String? event,
    github_api.Status? status,
    DateTime? created,
    int? checkSuiteId,
    String? headSha,
  }) async {
    return const github_api.ListWorkflowRunsResponse(
      totalCount: 0,
      workflowRuns: [],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeReposClient implements github_api.ReposClient {
  const _FakeReposClient(this.contents);

  final Map<String, github_api.RepositoryContent> contents;

  @override
  Future<github_api.RepositoryContent> getRepositoryContent({
    required String owner,
    required String repo,
    required String path,
    String? ref,
  }) async {
    final content = contents[path];
    if (content == null) throw StateError('Missing content: $path');
    return content;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
