// หน้าที่หลัก: Model และการแปลงข้อมูล JSON สำหรับข้อมูลโฟลิโอ
import 'localized_text.dart';

class Project {
  Project({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.description,
    required this.highlights,
    required this.tags,
    required this.images,
    required this.featured,
    this.updatedAt,
  });
  final String id;
  final LocalizedText title;
  final LocalizedText category;
  final LocalizedText summary;
  final LocalizedText description;
  final List<LocalizedText> highlights;
  final List<String> tags;
  final List<String> images;
  final bool featured;
  final DateTime? updatedAt;

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as String? ?? '',
    title: LocalizedText.fromJson(json['title']),
    category: LocalizedText.fromJson(json['category']),
    summary: LocalizedText.fromJson(json['summary']),
    description: LocalizedText.fromJson(json['description']),
    highlights: (json['highlights'] as List<dynamic>? ?? const [])
        .map(LocalizedText.fromJson)
        .toList(),
    tags: (json['tags'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(),
    images: (json['images'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(),
    featured: json['featured'] as bool? ?? false,
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
  );
}

List<Project> sortProjectsByFeaturedAndUpdated(Iterable<Project> projects) {
  final indexed = projects.toList().asMap().entries.toList();
  indexed.sort((first, second) {
    if (first.value.featured != second.value.featured) {
      return first.value.featured ? -1 : 1;
    }

    final firstUpdatedAt = first.value.updatedAt;
    final secondUpdatedAt = second.value.updatedAt;
    if (firstUpdatedAt != null && secondUpdatedAt != null) {
      final updatedOrder = secondUpdatedAt.compareTo(firstUpdatedAt);
      if (updatedOrder != 0) return updatedOrder;
    } else if (firstUpdatedAt != null) {
      return -1;
    } else if (secondUpdatedAt != null) {
      return 1;
    }

    // หากวันที่เท่ากันให้คงลำดับเดิมจากไฟล์ข้อมูล
    return first.key.compareTo(second.key);
  });
  return indexed.map((entry) => entry.value).toList();
}
