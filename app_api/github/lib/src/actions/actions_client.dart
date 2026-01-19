// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/empty_object.dart';
import '../models/list_workflow_runs_response.dart';
import '../models/list_workflows_response.dart';
import '../models/rerun_workflow_request.dart';
import '../models/status.dart';
import '../models/workflow_dispatch_request.dart';
import '../models/workflow_run.dart';

part 'actions_client.g.dart';

@RestApi()
abstract class ActionsClient {
  factory ActionsClient(Dio dio, {String? baseUrl}) = _ActionsClient;

  /// List repository workflows.
  ///
  /// Lists the workflows in a repository.
  ///
  /// [owner] - The account owner of the repository.
  ///
  /// [repo] - The name of the repository without the `.git` extension.
  ///
  /// [perPage] - The number of results per page (max 100).
  ///
  /// [page] - Page number of the results to fetch.
  @GET('/repos/{owner}/{repo}/actions/workflows')
  Future<ListWorkflowsResponse> listWorkflows({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Query('per_page') int? perPage = 30,
    @Query('page') int? page = 1,
  });

  /// List workflow runs for a repository.
  ///
  /// Lists all workflow runs for a repository. You can use parameters to narrow the list of results.
  ///
  /// [owner] - The account owner of the repository.
  ///
  /// [repo] - The name of the repository without the `.git` extension.
  ///
  /// [actor] - Returns someone's workflow runs. Use the login for the user who created the `push` associated with the check suite or workflow run.
  ///
  /// [branch] - Returns workflow runs associated with a branch. Use the name of the branch of the `push`.
  ///
  /// [event] - Returns workflow run triggered by the event you specify. For example, `push`, `pull_request` or `issue`.
  ///
  /// [status] - Returns workflow runs with the check run status or conclusion that you specify.
  ///
  /// [perPage] - The number of results per page (max 100).
  ///
  /// [page] - Page number of the results to fetch.
  ///
  /// [created] - Returns workflow runs created within the given date-time range.
  ///
  /// [excludePullRequests] - If `true` pull requests are omitted from the response.
  ///
  /// [checkSuiteId] - Returns workflow runs with the check_suite_id that you specify.
  ///
  /// [headSha] - Only returns workflow runs that are associated with the specified head_sha.
  @GET('/repos/{owner}/{repo}/actions/runs')
  Future<ListWorkflowRunsResponse> listWorkflowRuns({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Query('per_page') int? perPage = 30,
    @Query('page') int? page = 1,
    @Query('exclude_pull_requests') bool? excludePullRequests = false,
    @Query('actor') String? actor,
    @Query('branch') String? branch,
    @Query('event') String? event,
    @Query('status') Status? status,
    @Query('created') DateTime? created,
    @Query('check_suite_id') int? checkSuiteId,
    @Query('head_sha') String? headSha,
  });

  /// List workflow runs for a workflow.
  ///
  /// List all workflow runs for a workflow. You can replace `workflow_id` with the workflow file name.
  ///
  /// [owner] - The account owner of the repository.
  ///
  /// [repo] - The name of the repository without the `.git` extension.
  ///
  /// [workflowId] - The ID of the workflow. You can also pass the workflow file name as a string.
  ///
  /// [actor] - Returns someone's workflow runs.
  ///
  /// [branch] - Returns workflow runs associated with a branch.
  ///
  /// [event] - Returns workflow run triggered by the event you specify.
  ///
  /// [status] - Returns workflow runs with the check run status or conclusion that you specify.
  ///
  /// [perPage] - The number of results per page (max 100).
  ///
  /// [page] - Page number of the results to fetch.
  ///
  /// [created] - Returns workflow runs created within the given date-time range.
  ///
  /// [excludePullRequests] - If `true` pull requests are omitted from the response.
  ///
  /// [checkSuiteId] - Returns workflow runs with the check_suite_id that you specify.
  ///
  /// [headSha] - Only returns workflow runs that are associated with the specified head_sha.
  @GET('/repos/{owner}/{repo}/actions/workflows/{workflow_id}/runs')
  Future<ListWorkflowRunsResponse> listWorkflowRunsForWorkflow({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('workflow_id') required String workflowId,
    @Query('per_page') int? perPage = 30,
    @Query('page') int? page = 1,
    @Query('exclude_pull_requests') bool? excludePullRequests = false,
    @Query('actor') String? actor,
    @Query('branch') String? branch,
    @Query('event') String? event,
    @Query('status') Status? status,
    @Query('created') DateTime? created,
    @Query('check_suite_id') int? checkSuiteId,
    @Query('head_sha') String? headSha,
  });

  /// Create a workflow dispatch event.
  ///
  /// You can use this endpoint to manually trigger a GitHub Actions workflow run.
  ///
  /// [owner] - The account owner of the repository.
  ///
  /// [repo] - The name of the repository without the `.git` extension.
  ///
  /// [workflowId] - The ID of the workflow. You can also pass the workflow file name as a string.
  @POST('/repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches')
  Future<void> createWorkflowDispatch({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('workflow_id') required String workflowId,
    @Body() required WorkflowDispatchRequest body,
  });

  /// Get a workflow run.
  ///
  /// Gets a specific workflow run.
  ///
  /// [owner] - The account owner of the repository.
  ///
  /// [repo] - The name of the repository without the `.git` extension.
  ///
  /// [runId] - The unique identifier of the workflow run.
  ///
  /// [excludePullRequests] - If `true` pull requests are omitted from the response.
  @GET('/repos/{owner}/{repo}/actions/runs/{run_id}')
  Future<WorkflowRun> getWorkflowRun({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('run_id') required int runId,
    @Query('exclude_pull_requests') bool? excludePullRequests = false,
  });

  /// Cancel a workflow run.
  ///
  /// Cancels a workflow run using its id.
  ///
  /// [owner] - The account owner of the repository.
  ///
  /// [repo] - The name of the repository without the `.git` extension.
  ///
  /// [runId] - The unique identifier of the workflow run.
  @POST('/repos/{owner}/{repo}/actions/runs/{run_id}/cancel')
  Future<EmptyObject> cancelWorkflowRun({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('run_id') required int runId,
  });

  /// Re-run a workflow.
  ///
  /// Re-runs your workflow run using its id.
  ///
  /// [owner] - The account owner of the repository.
  ///
  /// [repo] - The name of the repository without the `.git` extension.
  ///
  /// [runId] - The unique identifier of the workflow run.
  @POST('/repos/{owner}/{repo}/actions/runs/{run_id}/rerun')
  Future<EmptyObject> rerunWorkflow({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('run_id') required int runId,
    @Body() RerunWorkflowRequest? body,
  });

  /// Re-run failed jobs from a workflow run.
  ///
  /// Re-run all of the failed jobs and their dependent jobs in a workflow run using the id of the workflow run.
  ///
  /// [owner] - The account owner of the repository.
  ///
  /// [repo] - The name of the repository without the `.git` extension.
  ///
  /// [runId] - The unique identifier of the workflow run.
  @POST('/repos/{owner}/{repo}/actions/runs/{run_id}/rerun-failed-jobs')
  Future<EmptyObject> rerunWorkflowFailedJobs({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('run_id') required int runId,
    @Body() RerunWorkflowRequest? body,
  });
}
