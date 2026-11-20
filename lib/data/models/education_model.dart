// หน้าที่หลัก: Model และการแปลงข้อมูล JSON สำหรับข้อมูลโฟลิโอ
import 'localized_text.dart';

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
