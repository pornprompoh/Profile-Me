// หน้าที่หลัก: แสดง Tech Stack จากข้อมูลโปรไฟล์เป็นชิปขนาดกะทัดรัด
part of '../../../main.dart';

class _HeroTechStackRow extends StatelessWidget {
  const _HeroTechStackRow(this.skills, {required this.alignment});

  final List<String> skills;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: alignment,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final skill in skills)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: .20)),
            ),
            child: Text(
              skill,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: .88),
              ),
            ),
          ),
      ],
    );
  }
}
