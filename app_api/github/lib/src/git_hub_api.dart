// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'users/users_client.dart';
import 'repos/repos_client.dart';
import 'orgs/orgs_client.dart';
import 'actions/actions_client.dart';

/// GitHub REST API `v1.0.0`.
///
/// GitHub REST API client for managing repositories, users, organizations, and GitHub Actions.
/// This specification covers a subset of the GitHub API for the gsmlg app.
///
class GitHubApi {
  GitHubApi(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '1.0.0';

  UsersClient? _users;
  ReposClient? _repos;
  OrgsClient? _orgs;
  ActionsClient? _actions;

  UsersClient get users => _users ??= UsersClient(_dio, baseUrl: _baseUrl);

  ReposClient get repos => _repos ??= ReposClient(_dio, baseUrl: _baseUrl);

  OrgsClient get orgs => _orgs ??= OrgsClient(_dio, baseUrl: _baseUrl);

  ActionsClient get actions =>
      _actions ??= ActionsClient(_dio, baseUrl: _baseUrl);
}
