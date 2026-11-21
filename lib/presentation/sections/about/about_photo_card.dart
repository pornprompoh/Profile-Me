// หน้าที่หลัก: แสดงรูปประกอบนิ่งๆ ฝั่งซ้ายของบล็อก About
part of '../../../main.dart';

class _AboutPhotoCard extends StatelessWidget {
  const _AboutPhotoCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < LayoutTokens.mobileBreakpoint;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final path = profile.aboutImage.trim();

    return SizedBox(
      width: isMobile ? 280 : (width < 900 ? 260 : 348),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .14)
                  : AppColors.oceanSky.withValues(alpha: .28),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.oceanSky.withValues(alpha: isDark ? .12 : .16),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: path.isEmpty
                ? ColoredBox(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.person_outline_rounded, size: 64),
                    ),
                  )
                : Image.asset(
                    path,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, _, _) => ColoredBox(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.person_outline_rounded, size: 64),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
