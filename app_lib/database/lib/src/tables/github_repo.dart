import 'package:drift/drift.dart';

/// Drift table definition for pinned/selected GitHub repositories.
///
/// Stores which repositories should be shown in the GitHub service screen.
class GitHubRepoTable extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Repository ID from GitHub.
  IntColumn get repoId => integer()();

  /// Repository full name (owner/repo).
  TextColumn get fullName => text()();

  /// Repository name.
  TextColumn get name => text()();

  /// Owner login name.
  TextColumn get ownerLogin => text()();

  /// Owner avatar URL.
  TextColumn get ownerAvatarUrl => text().nullable()();

  /// Repository description.
  TextColumn get description => text().nullable()();

  /// Whether the repository is private.
  BoolColumn get isPrivate => boolean().withDefault(const Constant(false))();

  /// Default branch name.
  TextColumn get defaultBranch => text().withDefault(const Constant('main'))();

  /// Star count (cached).
  IntColumn get stargazersCount => integer().withDefault(const Constant(0))();

  /// Timestamp when the record was created.
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when the record was last updated.
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {repoId},
      ];
}
