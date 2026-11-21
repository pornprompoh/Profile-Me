import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:web/web.dart' as web;

import '../../core/state/app_state.dart';
import '../../data/models/content_models.dart';

class ResumePdfService {
  Future<void> download(
    Profile profile,
    Links links,
    List<Project> projects,
    AppLocale locale,
  ) async {
    final isThai = locale == AppLocale.th;
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/my_content/fonts/Sarabun-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/my_content/fonts/Sarabun-Bold.ttf'),
    );
    final pdf = pw.Document();

    pw.Widget text(
      String value, {
      double size = 10,
      pw.Font? font,
      PdfColor color = PdfColors.grey800,
    }) => pw.Text(
      value,
      style: pw.TextStyle(font: font ?? regular, fontSize: size, color: color),
    );

    pw.Widget sectionTitle(String value) => pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Text(
        value,
        style: pw.TextStyle(
          font: bold,
          fontSize: 14,
          color: const PdfColor.fromInt(0xFF2563EB),
        ),
      ),
    );

    pw.ImageProvider? image;
    if (profile.profileImage.isNotEmpty) {
      try {
        final bytes = (await rootBundle.load(
          profile.profileImage,
        )).buffer.asUint8List();
        image = pw.MemoryImage(bytes);
      } catch (_) {}
    }

    final name = isThai ? profile.names.th : profile.names.en;
    final role = isThai ? profile.roles.th : profile.roles.en;
    final bio = profile.resolvedBio(locale);
    final cleanName = name
        .replaceAll(RegExp(r'[<>:"/\\|?*\s]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final featured = projects.where((project) => project.featured).take(4);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (context) => pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 170,
              height: 805,
              padding: const pw.EdgeInsets.all(16),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFE0F2FE),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (image != null)
                    pw.Center(
                      child: pw.Container(
                        width: 118,
                        height: 118,
                        child: pw.ClipOval(child: pw.Image(image)),
                      ),
                    ),
                  pw.SizedBox(height: 14),
                  text(isThai ? 'ติดต่อ' : 'Contact', size: 13, font: bold),
                  pw.SizedBox(height: 6),
                  if (profile.email.isNotEmpty)
                    pw.UrlLink(
                      destination: 'mailto:${profile.email}',
                      child: text(profile.email, size: 9),
                    ),
                  for (final link in links.socialLinks.take(4))
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 5),
                      child: pw.UrlLink(
                        destination: link.url,
                        child: text(link.label, size: 9),
                      ),
                    ),
                  pw.SizedBox(height: 18),
                  text(isThai ? 'ทักษะ' : 'Skills', size: 13, font: bold),
                  for (final group in profile.skillGroups)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 7),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          text(
                            isThai ? group.title.th : group.title.en,
                            size: 10,
                            font: bold,
                          ),
                          pw.SizedBox(height: 3),
                          for (final skill in group.skills)
                            text(skill, size: 9),
                        ],
                      ),
                    ),
                  pw.SizedBox(height: 16),
                  text(isThai ? 'ภาษา' : 'Languages', size: 13, font: bold),
                  for (final language in profile.languages)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 5),
                      child: text(
                        '${isThai ? language.name.th : language.name.en} - ${isThai ? language.level.th : language.level.en}',
                        size: 9,
                      ),
                    ),
                ],
              ),
            ),
            pw.SizedBox(width: 18),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  text(
                    name,
                    size: 24,
                    font: bold,
                    color: const PdfColor.fromInt(0xFF0F172A),
                  ),
                  text(
                    role,
                    size: 12,
                    color: const PdfColor.fromInt(0xFF2563EB),
                  ),
                  pw.SizedBox(height: 14),
                  sectionTitle(isThai ? 'ประวัติส่วนตัว' : 'Summary'),
                  text(bio, size: 9),
                  pw.SizedBox(height: 12),
                  sectionTitle(isThai ? 'การศึกษา' : 'Education'),
                  for (final item in profile.education)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 7),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          text(
                            item.period,
                            size: 8,
                            color: const PdfColor.fromInt(0xFF2563EB),
                          ),
                          text(
                            isThai ? item.institution.th : item.institution.en,
                            size: 10,
                            font: bold,
                          ),
                          text(isThai ? item.field.th : item.field.en, size: 9),
                          if ((isThai ? item.details.th : item.details.en)
                              .isNotEmpty)
                            text(
                              isThai ? item.details.th : item.details.en,
                              size: 8,
                            ),
                        ],
                      ),
                    ),
                  pw.SizedBox(height: 8),
                  sectionTitle(isThai ? 'ประสบการณ์' : 'Experience'),
                  for (final item in profile.experience)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 7),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          text(
                            item.period,
                            size: 8,
                            color: const PdfColor.fromInt(0xFF2563EB),
                          ),
                          text(
                            isThai ? item.role.th : item.role.en,
                            size: 10,
                            font: bold,
                          ),
                          text(
                            isThai
                                ? item.organization.th
                                : item.organization.en,
                            size: 9,
                          ),
                          text(
                            isThai ? item.details.th : item.details.en,
                            size: 8,
                          ),
                        ],
                      ),
                    ),
                  pw.SizedBox(height: 8),
                  sectionTitle(isThai ? 'ผลงานเด่น' : 'Featured Projects'),
                  for (final project in featured)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 7),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          text(
                            isThai ? project.title.th : project.title.en,
                            size: 10,
                            font: bold,
                          ),
                          text(
                            isThai ? project.summary.th : project.summary.en,
                            size: 8,
                          ),
                          text(
                            project.tags.join('  ·  '),
                            size: 8,
                            color: const PdfColor.fromInt(0xFF2563EB),
                          ),
                          if (links.projectLinks
                              .where(
                                (link) =>
                                    link.projectId == project.id &&
                                    link.type == 'github',
                              )
                              .isNotEmpty)
                            pw.UrlLink(
                              destination: links.projectLinks
                                  .firstWhere(
                                    (link) =>
                                        link.projectId == project.id &&
                                        link.type == 'github',
                                  )
                                  .url,
                              child: text('GitHub', size: 8),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();
    final blob = web.Blob(
      <JSUint8Array>[Uint8List.fromList(bytes).toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = 'Resume_${cleanName}_${isThai ? 'TH' : 'EN'}.pdf';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }
}
