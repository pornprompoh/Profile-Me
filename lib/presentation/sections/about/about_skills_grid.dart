// หน้าที่หลัก: แสดงกลุ่มทักษะทั้ง 3 แบบกริดสมดุลใต้บล็อก About
part of '../../../main.dart';

class _AboutSkillsGrid extends StatelessWidget {
  const _AboutSkillsGrid({required this.groups, required this.locale});

  final List<SkillGroup> groups;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final columnCount = width < LayoutTokens.mobileBreakpoint
        ? 1
        : (width < 900 ? 2 : 3);
    final spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final group in groups)
              SizedBox(
                width: cardWidth,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 170),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale == AppLocale.th
                            ? group.title.th
                            : group.title.en,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final skill in group.skills)
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
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
