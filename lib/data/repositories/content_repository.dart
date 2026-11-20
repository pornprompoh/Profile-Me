import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/content_models.dart';

class ContentRepository {
  Future<Profile> loadProfile() async {
    final json = await rootBundle.loadString(
      'assets/my_content/profile/profile.json',
    );
    return Profile.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<List<Project>> loadProjects() async {
    final json = await rootBundle.loadString(
      'assets/my_content/projects/projects.json',
    );
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map(Project.fromJson)
        .where((project) => project.id.isNotEmpty)
        .toList();
  }

  Future<Links> loadLinks() async {
    final json = await rootBundle.loadString(
      'assets/my_content/links/links.json',
    );
    final map = jsonDecode(json) as Map<String, dynamic>;
    final social = (map['socialLinks'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => SocialLink(
            item['label'] as String? ?? '',
            item['url'] as String? ?? '',
            item['icon'] as String? ?? '',
          ),
        )
        .where((link) => link.url.isNotEmpty)
        .toList();
    final project = (map['projectLinks'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => ProjectLink(
            item['projectId'] as String? ?? '',
            item['type'] as String? ?? '',
            LocalizedText.fromJson(item['label']),
            item['url'] as String? ?? '',
          ),
        )
        .where((link) => link.projectId.isNotEmpty && link.url.isNotEmpty)
        .toList();
    return Links(social, project);
  }
}
