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
}
