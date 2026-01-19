import 'package:dio/dio.dart';
import 'package:github_api/github_api.dart';
import 'package:test/test.dart';

void main() {
  group('GitHubApi', () {
    test('can be instantiated', () {
      final dio = Dio(BaseOptions(
        baseUrl: 'https://api.github.com',
        headers: {
          'Authorization': 'Bearer test_token',
          'Accept': 'application/vnd.github+json',
        },
      ));
      final api = GitHubApi(dio);
      expect(api, isNotNull);
      expect(api.users, isNotNull);
      expect(api.repos, isNotNull);
      expect(api.orgs, isNotNull);
      expect(api.actions, isNotNull);
      dio.close();
    });
  });
}
