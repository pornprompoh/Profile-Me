// หน้าที่หลัก: Model และการแปลงข้อมูล JSON สำหรับข้อมูลโฟลิโอ
import 'localized_text.dart';

class SkillGroup {
  SkillGroup(this.title, this.skills);
  final LocalizedText title;
  final List<String> skills;

  factory SkillGroup.fromJson(Map<String, dynamic> json) => SkillGroup(
    LocalizedText.fromJson(json['title']),
    (json['skills'] as List<dynamic>? ?? const []).whereType<String>().toList(),
  );
}
