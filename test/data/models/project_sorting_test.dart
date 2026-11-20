import 'package:flutter_test/flutter_test.dart';
import 'package:profile_me/data/models/content_models.dart';

void main() {
  test('Project.fromJson accepts data without updatedAt', () {
    final project = Project.fromJson({'id': 'legacy-project'});

    expect(project.updatedAt, isNull);
  });

  test('sorts featured projects first, then by update date stably', () {
    final projects = [
      _project('newest', updatedAt: DateTime(2026, 11, 20)),
      _project('featured-older', featured: true, updatedAt: DateTime(2026, 1)),
      _project('same-date-first', updatedAt: DateTime(2025, 1)),
      _project('same-date-second', updatedAt: DateTime(2025, 1)),
      _project('no-date'),
    ];

    final sorted = sortProjectsByFeaturedAndUpdated(projects);

    expect(sorted.map((project) => project.id), [
      'featured-older',
      'newest',
      'same-date-first',
      'same-date-second',
      'no-date',
    ]);
  });
}

Project _project(String id, {bool featured = false, DateTime? updatedAt}) =>
    Project(
      id: id,
      title: LocalizedText(id, id),
      category: LocalizedText('เว็บแอป', 'Web App'),
      summary: LocalizedText('', ''),
      description: LocalizedText('', ''),
      highlights: const [],
      tags: const [],
      images: const [],
      featured: featured,
      updatedAt: updatedAt,
    );
