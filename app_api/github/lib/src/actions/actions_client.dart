import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/dispatch_request.dart';
import '../models/workflow.dart';
import '../models/workflow_run.dart';

part 'actions_client.g.dart';

/// GitHub Actions API client.
@RestApi()
abstract class ActionsClient {
  factory ActionsClient(Dio dio, {String? baseUrl}) = _ActionsClient;

  /// List repository workflows.
  @GET('/repos/{owner}/{repo}/actions/workflows')
  Future<ListWorkflowsResponse> listWorkflows({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Query('per_page') int? perPage = 100,
    @Query('page') int? page = 1,
  });

  /// Get a workflow.
  @GET('/repos/{owner}/{repo}/actions/workflows/{workflow_id}')
  Future<WorkflowResponse> getWorkflow({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('workflow_id') required String workflowId,
  });

  /// List workflow runs for a repository.
  @GET('/repos/{owner}/{repo}/actions/runs')
  Future<ListWorkflowRunsResponse> listWorkflowRuns({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Query('actor') String? actor,
    @Query('branch') String? branch,
    @Query('event') String? event,
    @Query('status') String? status,
    @Query('per_page') int? perPage = 30,
    @Query('page') int? page = 1,
  });

  /// List workflow runs for a specific workflow.
  @GET('/repos/{owner}/{repo}/actions/workflows/{workflow_id}/runs')
  Future<ListWorkflowRunsResponse> listWorkflowRunsForWorkflow({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('workflow_id') required String workflowId,
    @Query('actor') String? actor,
    @Query('branch') String? branch,
    @Query('event') String? event,
    @Query('status') String? status,
    @Query('per_page') int? perPage = 30,
    @Query('page') int? page = 1,
  });

  /// Get a workflow run.
  @GET('/repos/{owner}/{repo}/actions/runs/{run_id}')
  Future<WorkflowRunResponse> getWorkflowRun({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('run_id') required int runId,
  });

  /// Create a workflow dispatch event.
  @POST('/repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches')
  Future<void> createWorkflowDispatch({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('workflow_id') required String workflowId,
    @Body() required WorkflowDispatchRequest request,
  });

  /// Re-run a workflow.
  @POST('/repos/{owner}/{repo}/actions/runs/{run_id}/rerun')
  Future<void> rerunWorkflow({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('run_id') required int runId,
  });

  /// Cancel a workflow run.
  @POST('/repos/{owner}/{repo}/actions/runs/{run_id}/cancel')
  Future<void> cancelWorkflowRun({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('run_id') required int runId,
  });

  /// Delete a workflow run.
  @DELETE('/repos/{owner}/{repo}/actions/runs/{run_id}')
  Future<void> deleteWorkflowRun({
    @Path('owner') required String owner,
    @Path('repo') required String repo,
    @Path('run_id') required int runId,
  });
}
