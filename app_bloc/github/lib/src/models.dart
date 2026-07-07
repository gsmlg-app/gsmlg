import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:github_api/github_api.dart';

/// GitHub Repository model
@immutable
class GitHubRepo extends Equatable {
  const GitHubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.owner,
    this.description,
    this.htmlUrl,
    this.private = false,
    this.fork = false,
    this.stargazersCount = 0,
    this.watchersCount = 0,
    this.forksCount = 0,
    this.openIssuesCount = 0,
    this.defaultBranch,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String fullName;
  final GitHubOwner owner;
  final String? description;
  final String? htmlUrl;
  final bool private;
  final bool fork;
  final int stargazersCount;
  final int watchersCount;
  final int forksCount;
  final int openIssuesCount;
  final String? defaultBranch;
  final DateTime? updatedAt;

  factory GitHubRepo.fromJson(Map<String, dynamic> json) {
    return GitHubRepo(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      owner: GitHubOwner.fromJson(json['owner'] as Map<String, dynamic>),
      description: json['description'] as String?,
      htmlUrl: json['html_url'] as String?,
      private: json['private'] as bool? ?? false,
      fork: json['fork'] as bool? ?? false,
      stargazersCount: json['stargazers_count'] as int? ?? 0,
      watchersCount: json['watchers_count'] as int? ?? 0,
      forksCount: json['forks_count'] as int? ?? 0,
      openIssuesCount: json['open_issues_count'] as int? ?? 0,
      defaultBranch: json['default_branch'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  factory GitHubRepo.fromApiResponse(Repository response) {
    return GitHubRepo(
      id: response.id,
      name: response.name,
      fullName: response.fullName,
      owner: GitHubOwner.fromApiResponse(response.owner),
      description: response.description,
      htmlUrl: response.htmlUrl,
      private: response.private,
      fork: response.fork,
      stargazersCount: response.stargazersCount ?? 0,
      watchersCount: response.watchersCount ?? 0,
      forksCount: response.forksCount ?? 0,
      openIssuesCount: response.openIssuesCount ?? 0,
      defaultBranch: response.defaultBranch,
      updatedAt: response.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, fullName, owner];
}

/// GitHub Owner (user or org)
@immutable
class GitHubOwner extends Equatable {
  const GitHubOwner({
    required this.id,
    required this.login,
    required this.type,
    this.avatarUrl,
  });

  final int id;
  final String login;
  final String type; // "User" or "Organization"
  final String? avatarUrl;

  bool get isOrganization => type == 'Organization';

  factory GitHubOwner.fromJson(Map<String, dynamic> json) {
    return GitHubOwner(
      id: json['id'] as int,
      login: json['login'] as String,
      type: json['type'] as String? ?? 'User',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  factory GitHubOwner.fromApiResponse(SimpleUser response) {
    return GitHubOwner(
      id: response.id,
      login: response.login,
      type: response.type ?? 'User',
      avatarUrl: response.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, login, type];
}

/// GitHub Workflow (Actions)
@immutable
class GitHubWorkflow extends Equatable {
  const GitHubWorkflow({
    required this.id,
    required this.name,
    required this.path,
    required this.state,
    this.htmlUrl,
    this.badgeUrl,
    this.inputs = const [],
  });

  final int id;
  final String name;
  final String path;
  final String state; // "active", "disabled_manually", etc.
  final String? htmlUrl;
  final String? badgeUrl;
  final List<GitHubWorkflowInput> inputs;

  bool get isActive => state == 'active';
  bool get hasInputs => inputs.isNotEmpty;

  GitHubWorkflow copyWith({List<GitHubWorkflowInput>? inputs}) {
    return GitHubWorkflow(
      id: id,
      name: name,
      path: path,
      state: state,
      htmlUrl: htmlUrl,
      badgeUrl: badgeUrl,
      inputs: inputs ?? this.inputs,
    );
  }

  factory GitHubWorkflow.fromJson(Map<String, dynamic> json) {
    return GitHubWorkflow(
      id: json['id'] as int,
      name: json['name'] as String,
      path: json['path'] as String,
      state: json['state'] as String? ?? 'unknown',
      htmlUrl: json['html_url'] as String?,
      badgeUrl: json['badge_url'] as String?,
      inputs:
          (json['inputs'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(GitHubWorkflowInput.fromJson)
              .toList() ??
          const [],
    );
  }

  factory GitHubWorkflow.fromApiResponse(Workflow response) {
    return GitHubWorkflow(
      id: response.id,
      name: response.name,
      path: response.path,
      state: response.state.name,
      htmlUrl: response.htmlUrl,
      badgeUrl: response.badgeUrl,
    );
  }

  @override
  List<Object?> get props => [id, name, path, state, inputs];
}

/// GitHub workflow_dispatch input metadata
@immutable
class GitHubWorkflowInput extends Equatable {
  const GitHubWorkflowInput({
    required this.name,
    this.description,
    this.defaultValue,
    this.required = false,
    this.type,
    this.options = const [],
  });

  final String name;
  final String? description;
  final String? defaultValue;
  final bool required;
  final String? type;
  final List<String> options;

  bool get isChoice => type == 'choice' && options.isNotEmpty;
  bool get isBoolean => type == 'boolean';

  factory GitHubWorkflowInput.fromJson(Map<String, dynamic> json) {
    return GitHubWorkflowInput(
      name: json['name'] as String,
      description: json['description'] as String?,
      defaultValue: json['default']?.toString(),
      required: json['required'] as bool? ?? false,
      type: json['type']?.toString(),
      options:
          (json['options'] as List<dynamic>?)
              ?.map((option) => option.toString())
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [
    name,
    description,
    defaultValue,
    required,
    type,
    options,
  ];
}

/// GitHub Workflow Run
@immutable
class GitHubWorkflowRun extends Equatable {
  const GitHubWorkflowRun({
    required this.id,
    required this.name,
    required this.workflowId,
    required this.status,
    this.conclusion,
    this.headBranch,
    this.headSha,
    this.htmlUrl,
    this.createdAt,
    this.updatedAt,
    this.runNumber,
    this.event,
  });

  final int id;
  final String? name;
  final int workflowId;
  final String status; // "queued", "in_progress", "completed"
  final String? conclusion; // "success", "failure", "cancelled", etc.
  final String? headBranch;
  final String? headSha;
  final String? htmlUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? runNumber;
  final String? event; // "push", "pull_request", "workflow_dispatch", etc.

  bool get isCompleted => status == 'completed';
  bool get isSuccess => conclusion == 'success';
  bool get isFailure => conclusion == 'failure';
  bool get isRunning => status == 'inProgress' || status == 'queued';

  factory GitHubWorkflowRun.fromJson(Map<String, dynamic> json) {
    return GitHubWorkflowRun(
      id: json['id'] as int,
      name: json['name'] as String?,
      workflowId: json['workflow_id'] as int,
      status: json['status'] as String? ?? 'unknown',
      conclusion: json['conclusion'] as String?,
      headBranch: json['head_branch'] as String?,
      headSha: json['head_sha'] as String?,
      htmlUrl: json['html_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      runNumber: json['run_number'] as int?,
      event: json['event'] as String?,
    );
  }

  factory GitHubWorkflowRun.fromApiResponse(WorkflowRun response) {
    return GitHubWorkflowRun(
      id: response.id,
      name: response.name ?? response.displayTitle,
      workflowId: response.workflowId,
      status: response.status?.name ?? 'unknown',
      conclusion: response.conclusion?.name,
      headBranch: response.headBranch,
      headSha: response.headSha,
      htmlUrl: response.htmlUrl,
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
      runNumber: response.runNumber,
      event: response.event,
    );
  }

  @override
  List<Object?> get props => [id, workflowId, status, conclusion];
}

/// GitHub Organization
@immutable
class GitHubOrg extends Equatable {
  const GitHubOrg({
    required this.id,
    required this.login,
    this.description,
    this.avatarUrl,
  });

  final int id;
  final String login;
  final String? description;
  final String? avatarUrl;

  factory GitHubOrg.fromJson(Map<String, dynamic> json) {
    return GitHubOrg(
      id: json['id'] as int,
      login: json['login'] as String,
      description: json['description'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  factory GitHubOrg.fromApiResponse(Organization response) {
    return GitHubOrg(
      id: response.id,
      login: response.login,
      description: response.description,
      avatarUrl: response.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, login];
}
