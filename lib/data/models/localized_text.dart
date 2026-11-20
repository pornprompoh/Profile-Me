// หน้าที่หลัก: Model และการแปลงข้อมูล JSON สำหรับข้อมูลโฟลิโอ
class LocalizedText {
  LocalizedText(this.th, this.en);

  final String th;
  final String en;

  factory LocalizedText.fromJson(dynamic json) => LocalizedText(
    (json is Map && json['th'] is String) ? json['th'] as String : '',
    (json is Map && json['en'] is String) ? json['en'] as String : '',
  );
}
