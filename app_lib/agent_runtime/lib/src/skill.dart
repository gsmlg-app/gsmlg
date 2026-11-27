import 'package:equatable/equatable.dart';

/// Lightweight metadata describing a discovered `SKILL.md` file.
class DirectorySkillMetadata extends Equatable {
  const DirectorySkillMetadata({
    required this.name,
    required this.description,
    required this.pathToSkillMd,
  });

  final String name;
  final String description;
  final String pathToSkillMd;

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'pathToSkillMd': pathToSkillMd,
  };

  factory DirectorySkillMetadata.fromJson(Map<String, dynamic> json) =>
      DirectorySkillMetadata(
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        pathToSkillMd: json['pathToSkillMd'] as String? ?? '',
      );

  @override
  List<Object?> get props => [name, description, pathToSkillMd];
}
