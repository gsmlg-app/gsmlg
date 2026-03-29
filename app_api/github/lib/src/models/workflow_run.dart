// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'commit.dart';
import 'minimal_repository.dart';
import 'pull_request_minimal.dart';
import 'referenced_workflow.dart';
import 'simple_user.dart';
import 'workflow_run_conclusion.dart';
import 'workflow_run_status.dart';

part 'workflow_run.g.dart';

/// A GitHub Actions workflow run
@JsonSerializable()
class WorkflowRun {
  const WorkflowRun({
    required this.workflowId,
    required this.event,
    required this.headSha,
    required this.id,
    this.headBranch,
    this.name,
    this.nodeId,
    this.path,
    this.displayTitle,
    this.runNumber,
    this.runAttempt,
    this.referencedWorkflows,
    this.checkSuiteId,
    this.status,
    this.conclusion,
    this.checkSuiteNodeId,
    this.url,
    this.htmlUrl,
    this.pullRequests,
    this.createdAt,
    this.updatedAt,
    this.actor,
    this.headRepository,
    this.runStartedAt,
    this.jobsUrl,
    this.logsUrl,
    this.checkSuiteUrl,
    this.artifactsUrl,
    this.cancelUrl,
    this.rerunUrl,
    this.previousAttemptUrl,
    this.workflowUrl,
    this.headCommit,
    this.repository,
    this.triggeringActor,
  });

  factory WorkflowRun.fromJson(Map<String, Object?> json) =>
      _$WorkflowRunFromJson(json);

  /// The ID of the workflow run
  final int id;

  /// The name of the workflow run
  final String? name;
  @JsonKey(name: 'node_id')
  final String? nodeId;
  @JsonKey(name: 'check_suite_id')
  final int? checkSuiteId;
  @JsonKey(name: 'check_suite_node_id')
  final String? checkSuiteNodeId;

  /// The branch of the head commit
  @JsonKey(name: 'head_branch')
  final String? headBranch;

  /// The SHA of the head commit
  @JsonKey(name: 'head_sha')
  final String headSha;
  final String? path;

  /// Title of the workflow run
  @JsonKey(name: 'display_title')
  final String? displayTitle;

  /// The auto incrementing run number for the workflow run
  @JsonKey(name: 'run_number')
  final int? runNumber;
  @JsonKey(name: 'run_attempt')
  final int? runAttempt;
  @JsonKey(name: 'referenced_workflows')
  final List<ReferencedWorkflow>? referencedWorkflows;

  /// The event that triggered the workflow run
  final String event;

  /// The status of the workflow run
  final WorkflowRunStatus? status;

  /// The conclusion of the workflow run
  final WorkflowRunConclusion? conclusion;

  /// The ID of the parent workflow
  @JsonKey(name: 'workflow_id')
  final int workflowId;
  final String? url;
  @JsonKey(name: 'html_url')
  final String? htmlUrl;
  @JsonKey(name: 'pull_requests')
  final List<PullRequestMinimal>? pullRequests;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  final SimpleUser? actor;
  @JsonKey(name: 'triggering_actor')
  final SimpleUser? triggeringActor;
  @JsonKey(name: 'run_started_at')
  final DateTime? runStartedAt;
  @JsonKey(name: 'jobs_url')
  final String? jobsUrl;
  @JsonKey(name: 'logs_url')
  final String? logsUrl;
  @JsonKey(name: 'check_suite_url')
  final String? checkSuiteUrl;
  @JsonKey(name: 'artifacts_url')
  final String? artifactsUrl;
  @JsonKey(name: 'cancel_url')
  final String? cancelUrl;
  @JsonKey(name: 'rerun_url')
  final String? rerunUrl;
  @JsonKey(name: 'previous_attempt_url')
  final String? previousAttemptUrl;
  @JsonKey(name: 'workflow_url')
  final String? workflowUrl;
  @JsonKey(name: 'head_commit')
  final Commit? headCommit;
  final MinimalRepository? repository;
  @JsonKey(name: 'head_repository')
  final MinimalRepository? headRepository;

  Map<String, Object?> toJson() => _$WorkflowRunToJson(this);
}
