import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:github_api/github_api.dart' as github_api;
import 'package:github_bloc/github_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('GitHubUser', () {
    test('fromJson creates user correctly', () {
      final json = {
        'id': 12345,
        'login': 'testuser',
        'name': 'Test User',
        'email': 'test@example.com',
        'avatar_url': 'https://example.com/avatar.png',
        'bio': 'A test user',
        'company': 'Test Co',
        'location': 'Test City',
        'blog': 'https://test.com',
        'public_repos': 10,
        'public_gists': 5,
        'followers': 100,
        'following': 50,
        'created_at': '2020-01-01T00:00:00Z',
      };

      final user = GitHubUser.fromJson(json);

      expect(user.id, 12345);
      expect(user.login, 'testuser');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
    });

    test('displayName returns login when name is null', () {
      final json = {'id': 12345, 'login': 'testuser', 'name': null};

      final user = GitHubUser.fromJson(json);

      expect(user.displayName, 'testuser');
    });
  });

  group('GitHubActionsBloc', () {
    const workflowPath = '.github/workflows/release.yml';

    blocTest<GitHubActionsBloc, GitHubActionsState>(
      'loads workflow_dispatch inputs from workflow file content',
      build: () => GitHubActionsBloc(
        api: _FakeGitHubApi(
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
name: Release
on:
  workflow_dispatch:
    inputs:
      version:
        description: Version to release
        required: true
        default: 1.2.3
        type: string
      platform:
        description: Platform target
        type: choice
        options:
          - android
          - macos
      dry_run:
        description: Validate without publishing
        default: true
        type: boolean
'''),
          },
        ),
        owner: 'gsmlg',
        repo: 'app',
      ),
      act: (bloc) => bloc.add(const GitHubActionsFetch()),
      expect: () => [
        const GitHubActionsLoading(),
        isA<GitHubActionsLoaded>()
            .having((state) => state.workflows.length, 'workflow count', 1)
            .having(
              (state) => state.workflows.single.inputs,
              'workflow inputs',
              const [
                GitHubWorkflowInput(
                  name: 'version',
                  description: 'Version to release',
                  defaultValue: '1.2.3',
                  required: true,
                  type: 'string',
                ),
                GitHubWorkflowInput(
                  name: 'platform',
                  description: 'Platform target',
                  type: 'choice',
                  options: ['android', 'macos'],
                ),
                GitHubWorkflowInput(
                  name: 'dry_run',
                  description: 'Validate without publishing',
                  defaultValue: 'true',
                  type: 'boolean',
                ),
              ],
            ),
      ],
    );

    blocTest<GitHubActionsBloc, GitHubActionsState>(
      'keeps workflow list usable when input metadata cannot be loaded',
      build: () => GitHubActionsBloc(
        api: _FakeGitHubApi(
          workflows: [
            const github_api.Workflow(
              id: 1,
              name: 'Release',
              path: workflowPath,
              state: github_api.WorkflowState.active,
            ),
          ],
        ),
        owner: 'gsmlg',
        repo: 'app',
      ),
      act: (bloc) => bloc.add(const GitHubActionsFetch()),
      expect: () => [
        const GitHubActionsLoading(),
        isA<GitHubActionsLoaded>().having(
          (state) => state.workflows.single.inputs,
          'workflow inputs',
          isEmpty,
        ),
      ],
    );

    blocTest<GitHubActionsBloc, GitHubActionsState>(
      'sends input arguments when dispatching a workflow',
      build: () {
        final api = _dispatchApi = _FakeGitHubApi(
          workflows: [
            const github_api.Workflow(
              id: 1,
              name: 'Release',
              path: workflowPath,
              state: github_api.WorkflowState.active,
            ),
          ],
        );
        return GitHubActionsBloc(api: api, owner: 'gsmlg', repo: 'app');
      },
      seed: () => const GitHubActionsLoaded(
        workflows: [
          GitHubWorkflow(
            id: 1,
            name: 'Release',
            path: workflowPath,
            state: 'active',
          ),
        ],
        runs: [],
      ),
      act: (bloc) {
        bloc.add(
          const GitHubActionsDispatch(
            workflowId: 1,
            ref: 'main',
            inputs: {'version': '1.2.4', 'dry_run': 'false'},
          ),
        );
      },
      wait: const Duration(milliseconds: 2300),
      expect: () => [
        isA<GitHubActionsLoaded>().having(
          (state) => state.isDispatching,
          'is dispatching',
          true,
        ),
        isA<GitHubActionsLoaded>().having(
          (state) => state.isDispatching,
          'is dispatching',
          false,
        ),
      ],
      verify: (_) {
        final api = _dispatchApi;
        expect(api.actionsClient.lastDispatch?.workflowId, '1');
        expect(api.actionsClient.lastDispatch?.body.ref, 'main');
        expect(api.actionsClient.lastDispatch?.body.inputs, {
          'version': '1.2.4',
          'dry_run': 'false',
        });
      },
    );
  });
}

late _FakeGitHubApi _dispatchApi;

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

class _FakeGitHubApi extends github_api.GitHubApi {
  _FakeGitHubApi({
    List<github_api.Workflow> workflows = const [],
    Map<String, github_api.RepositoryContent> contents = const {},
  }) : actionsClient = _FakeActionsClient(workflows: workflows),
       reposClient = _FakeReposClient(contents: contents),
       super(Dio());

  final _FakeActionsClient actionsClient;
  final _FakeReposClient reposClient;

  @override
  github_api.ActionsClient get actions => actionsClient;

  @override
  github_api.ReposClient get repos => reposClient;
}

class _WorkflowDispatchCall {
  const _WorkflowDispatchCall({required this.workflowId, required this.body});

  final String workflowId;
  final github_api.WorkflowDispatchRequest body;
}

class _FakeActionsClient implements github_api.ActionsClient {
  _FakeActionsClient({required this.workflows});

  final List<github_api.Workflow> workflows;
  _WorkflowDispatchCall? lastDispatch;

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
  Future<github_api.ListWorkflowRunsResponse> listWorkflowRunsForWorkflow({
    required String owner,
    required String repo,
    required String workflowId,
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
  Future<void> createWorkflowDispatch({
    required String owner,
    required String repo,
    required String workflowId,
    required github_api.WorkflowDispatchRequest body,
  }) async {
    lastDispatch = _WorkflowDispatchCall(workflowId: workflowId, body: body);
  }

  @override
  Future<github_api.WorkflowRun> getWorkflowRun({
    required String owner,
    required String repo,
    required int runId,
    bool? excludePullRequests = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<github_api.EmptyObject> cancelWorkflowRun({
    required String owner,
    required String repo,
    required int runId,
  }) async {}

  @override
  Future<github_api.EmptyObject> rerunWorkflow({
    required String owner,
    required String repo,
    required int runId,
    github_api.RerunWorkflowRequest? body,
  }) async {}

  @override
  Future<github_api.EmptyObject> rerunWorkflowFailedJobs({
    required String owner,
    required String repo,
    required int runId,
    github_api.RerunWorkflowRequest? body,
  }) async {}
}

class _FakeReposClient implements github_api.ReposClient {
  _FakeReposClient({required this.contents});

  final Map<String, github_api.RepositoryContent> contents;

  @override
  Future<List<github_api.Repository>> listReposForAuthenticatedUser({
    github_api.Direction? direction,
    github_api.Visibility? visibility = github_api.Visibility.all,
    String? affiliation = 'owner,collaborator,organization_member',
    github_api.Type? type = github_api.Type.all,
    github_api.Sort? sort = github_api.Sort.fullName,
    int? perPage = 30,
    int? page = 1,
  }) async {
    return const [];
  }

  @override
  Future<github_api.Repository> getRepo({
    required String owner,
    required String repo,
  }) {
    throw UnimplementedError();
  }

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
}
