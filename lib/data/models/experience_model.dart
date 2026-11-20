// หน้าที่หลัก: Model และการแปลงข้อมูล JSON สำหรับข้อมูลโฟลิโอ
import 'localized_text.dart';

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
