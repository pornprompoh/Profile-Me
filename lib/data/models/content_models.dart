class LocalizedText {
  LocalizedText(this.th, this.en);

  final String th;
  final String en;

  factory LocalizedText.fromJson(dynamic json) => LocalizedText(
    (json is Map && json['th'] is String) ? json['th'] as String : '',
    (json is Map && json['en'] is String) ? json['en'] as String : '',
  );
}

class Education {
  Education(this.period, this.institution, this.field, this.details);
  final String period;
  final LocalizedText institution;
  final LocalizedText field;
  final LocalizedText details;

  factory Education.fromJson(Map<String, dynamic> json) => Education(
    json['period'] as String? ?? '',
    LocalizedText.fromJson(json['institution']),
    LocalizedText.fromJson(json['field']),
    LocalizedText.fromJson(json['details']),
  );
}

class Experience {
  Experience(this.period, this.role, this.organization, this.details);
  final String period;
  final LocalizedText role;
  final LocalizedText organization;
  final LocalizedText details;

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
    json['period'] as String? ?? '',
    LocalizedText.fromJson(json['role']),
    LocalizedText.fromJson(json['organization']),
    LocalizedText.fromJson(json['details']),
  );
}

class SkillGroup {
  SkillGroup(this.title, this.skills);
  final LocalizedText title;
  final List<String> skills;

  factory SkillGroup.fromJson(Map<String, dynamic> json) => SkillGroup(
    LocalizedText.fromJson(json['title']),
    (json['skills'] as List<dynamic>? ?? const []).whereType<String>().toList(),
  );
}

class ProfileLanguage {
  ProfileLanguage(this.name, this.level);
  final LocalizedText name;
  final LocalizedText level;

  factory ProfileLanguage.fromJson(Map<String, dynamic> json) =>
      ProfileLanguage(
        LocalizedText.fromJson(json['name']),
        LocalizedText.fromJson(json['level']),
      );
}

class Profile {
  Profile({
    required this.names,
    required this.roles,
    required this.birthDate,
    required this.email,
    required this.bio,
    required this.education,
    required this.experience,
    required this.skillGroups,
    required this.languages,
    required this.profileImage,
  });

  final LocalizedText names;
  final LocalizedText roles;
  final String birthDate;
  final String email;
  final LocalizedText bio;
  final List<Education> education;
  final List<Experience> experience;
  final List<SkillGroup> skillGroups;
  final List<ProfileLanguage> languages;
  final String profileImage;

  int get age {
    final date = DateTime.tryParse(birthDate);
    if (date == null) return 0;
    final now = DateTime.now();
    var value = now.year - date.year;
    if (now.month < date.month ||
        (now.month == date.month && now.day < date.day)) {
      value--;
    }
    return value < 0 ? 0 : value;
  }

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    names: LocalizedText.fromJson(json['names']),
    roles: LocalizedText.fromJson(json['roles']),
    birthDate: json['birthDate'] as String? ?? '',
    email: json['email'] as String? ?? '',
    bio: LocalizedText.fromJson(json['bio']),
    education: (json['education'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Education.fromJson)
        .toList(),
    experience: (json['experience'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Experience.fromJson)
        .toList(),
    skillGroups: (json['skillGroups'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SkillGroup.fromJson)
        .toList(),
    languages: (json['languages'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ProfileLanguage.fromJson)
        .toList(),
    profileImage: json['profileImage'] as String? ?? '',
  );
}

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

class SocialLink {
  SocialLink(this.label, this.url, this.icon);
  final String label;
  final String url;
  final String icon;
}

class ProjectLink {
  ProjectLink(this.projectId, this.type, this.label, this.url);
  final String projectId;
  final String type;
  final LocalizedText label;
  final String url;
}

class Links {
  Links(this.socialLinks, this.projectLinks);
  final List<SocialLink> socialLinks;
  final List<ProjectLink> projectLinks;
}
