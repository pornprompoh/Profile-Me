// หน้าที่หลัก: แสดง 4 กิจกรรมเป็นการ์ดข้อมูลนิ่งสำหรับหน้า About
part of '../../../main.dart';

class _AboutActivitiesGrid extends StatelessWidget {
  const _AboutActivitiesGrid({required this.activities, required this.locale});

  final List<AboutActivity> activities;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < LayoutTokens.mobileBreakpoint;
    final columnCount = isMobile ? 1 : 2;
    const icons = <IconData>[
      Icons.language_rounded,
      Icons.auto_awesome_rounded,
      Icons.view_in_ar_rounded,
      Icons.school_rounded,
    ];

    if (activities.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = isMobile ? 10.0 : 12.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var index = 0; index < activities.length && index < 4; index++)
              SizedBox(
                width: cardWidth,
                child: _ActivityCard(
                  activity: activities[index],
                  locale: locale,
                  icon: icons[index],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.locale,
    required this.icon,
  });

  final AboutActivity activity;
  final AppLocale locale;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = locale == AppLocale.th
        ? activity.title.th
        : activity.title.en;
    final description = locale == AppLocale.th
        ? activity.description.th
        : activity.description.en;

    return Container(
      constraints: const BoxConstraints(minHeight: 142),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.oceanSky),
          const SizedBox(height: 9),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.45,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
