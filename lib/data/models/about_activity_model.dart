// หน้าที่หลัก: Model สำหรับกิจกรรมและสิ่งที่สนใจในส่วน About
import 'localized_text.dart';

class AboutActivity {
  const AboutActivity({required this.title, required this.description});

  final LocalizedText title;
  final LocalizedText description;

  factory AboutActivity.fromJson(Map<String, dynamic> json) => AboutActivity(
    title: LocalizedText.fromJson(json['title']),
    description: LocalizedText.fromJson(json['description']),
  );
}
