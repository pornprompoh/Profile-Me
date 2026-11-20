// หน้าที่หลัก: Model และการแปลงข้อมูล JSON สำหรับข้อมูลโฟลิโอ
import 'localized_text.dart';

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
