import 'package:github_api/github_api.dart';
import 'package:test/test.dart';

void main() {
  group('GitHubApi', () {
    test('can be instantiated', () {
      final api = GitHubApi(token: 'test_token');
      expect(api, isNotNull);
      expect(api.users, isNotNull);
      expect(api.repos, isNotNull);
      expect(api.actions, isNotNull);
      api.close();
    });
  });
}
