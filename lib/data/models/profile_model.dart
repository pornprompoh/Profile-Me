// หน้าที่หลัก: Model และการแปลงข้อมูล JSON สำหรับข้อมูลโปรไฟล์
import 'education_model.dart';
import 'experience_model.dart';
import 'localized_text.dart';
import 'profile_language_model.dart';
import 'skill_group_model.dart';

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
    LocalizedText? heroTagline,
  }) : heroTagline = heroTagline ?? LocalizedText('', '');

  final LocalizedText names;
  final LocalizedText roles;
  final String birthDate;
  final String email;
  final LocalizedText bio;
  final LocalizedText heroTagline;
  final List<Education> education;
  final List<Experience> experience;
  final List<SkillGroup> skillGroups;
  final List<ProfileLanguage> languages;
  final String profileImage;

  String get englishFirstName {
    final englishName = names.en.trim();
    return englishName.isEmpty ? '' : englishName.split(RegExp(r'\s+')).first;
  }

  // ลายน้ำใช้เฉพาะชื่อภาษาอังกฤษคำแรก ไม่รวมชื่อสกุล
  String get englishNameWatermark {
    final englishName = names.en.trim();
    return englishName.isEmpty
        ? ''
        : englishName.split(RegExp(r'\s+')).first.toUpperCase();
  }

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
    heroTagline: LocalizedText.fromJson(json['heroTagline']),
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
