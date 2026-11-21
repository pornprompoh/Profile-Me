// หน้าที่หลัก: รวมกลุ่มทักษะทั้ง 3 ใน Surface ใบเดียวในคอลัมน์ขวา
part of '../../../main.dart';

class _AboutSkillsGrid extends StatelessWidget {
  const _AboutSkillsGrid({required this.groups, required this.locale});

  final List<SkillGroup> groups;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1F33) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < groups.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            Text(
              locale == AppLocale.th
                  ? groups[index].title.th
                  : groups[index].title.en,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final skill in groups[index].skills)
                  Chip(
                    label: Text(skill),
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceRaised
                        : AppColors.lightSurfaceSoft,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
