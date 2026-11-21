// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../../../main.dart';

class _Hero extends StatelessWidget {
  const _Hero(
    this.profile,
    this.locale, {
    required this.onProjects,
    required this.onContact,
  });
  final Profile profile;
  final AppLocale locale;
  final VoidCallback onProjects;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = width < LayoutTokens.mobileBreakpoint;
    final isStacked = width < 720;
    final isCompact = width < 900;
    final name = locale == AppLocale.th ? profile.names.th : profile.names.en;
    final role = locale == AppLocale.th ? profile.roles.th : profile.roles.en;
    final caption = AppStrings.profileCaption(locale);
    final tagline =
        (locale == AppLocale.th
                ? profile.heroTagline.th
                : profile.heroTagline.en)
            .trim();
    final identity = _ScrollReveal(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isStacked
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            locale == AppLocale.th ? 'สวัสดีครับ ผมคือ' : "Hello, I'm",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white.withValues(alpha: .88),
            ),
            textAlign: isStacked ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: LayoutTokens.heroNameSize(context),
              height: 1.12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: isStacked ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            role,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: LayoutTokens.heroRoleSize(context),
              height: 1.35,
              color: AppColors.darkAccent,
            ),
            textAlign: isStacked ? TextAlign.center : TextAlign.start,
          ),
          if (tagline.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              tagline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: .78),
                fontSize: 15,
              ),
              textAlign: isStacked ? TextAlign.center : TextAlign.start,
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            alignment: isStacked ? WrapAlignment.center : WrapAlignment.start,
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onProjects,
                icon: const Icon(Icons.grid_view_rounded),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.lightOceanDeep,
                  minimumSize: const Size(0, LayoutTokens.touchTarget),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      LayoutTokens.controlRadius,
                    ),
                  ),
                ),
                label: Text(
                  locale == AppLocale.th ? 'ดูผลงาน' : 'View Projects',
                ),
              ),
              OutlinedButton.icon(
                onPressed: onContact,
                icon: const Icon(Icons.mail_outline),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: .48)),
                  minimumSize: const Size(0, LayoutTokens.touchTarget),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      LayoutTokens.controlRadius,
                    ),
                  ),
                ),
                label: Text(
                  locale == AppLocale.th ? 'ติดต่อฉัน' : 'Contact Me',
                ),
              ),
            ],
          ),
        ],
      ),
    );
    final image = _ScrollReveal(
      delay: const Duration(milliseconds: 120),
      child: _HoverWrapper(
        lift: 8,
        child: _HeroProfileCard(
          paths: profile.profileImages.isNotEmpty
              ? profile.profileImages
              : (profile.profileImage.isNotEmpty
                    ? [profile.profileImage]
                    : const []),
          width: isMobile ? 190 : (isCompact ? 220 : 260),
          caption: caption,
        ),
      ),
    );
    return SectionContainer(
      verticalPadding: isStacked ? (isMobile ? 36 : 52) : (isCompact ? 56 : 64),
      background: IgnorePointer(
        child: _HeroOceanBackdrop(
          isDark: isDark,
          watermark: profile.englishNameWatermark,
        ),
      ),
      child: isStacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [image, const SizedBox(height: 24), identity],
            )
          : Row(
              children: [
                Expanded(child: identity),
                SizedBox(width: isCompact ? 32 : 48),
                SizedBox(
                  width: isCompact ? 264 : 304,
                  child: Center(child: image),
                ),
              ],
            ),
    );
  }
}
