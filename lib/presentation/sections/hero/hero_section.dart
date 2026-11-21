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
            locale == AppLocale.th ? 'สวัสดีครับ ผมชื่อ' : 'Hello, I am',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: isStacked ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: LayoutTokens.heroNameSize(context),
              height: 1.12,
              fontWeight: FontWeight.w800,
            ),
            textAlign: isStacked ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            role,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: LayoutTokens.heroRoleSize(context),
              height: 1.35,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkAccent
                  : AppTheme.primary,
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          if (profile.heroTechStack.isNotEmpty) ...[
            const SizedBox(height: 16),
            _HeroTechStackRow(
              profile.heroTechStack,
              alignment: isStacked ? WrapAlignment.center : WrapAlignment.start,
            ),
          ],
        ],
      ),
    );
    final image = _ScrollReveal(
      delay: const Duration(milliseconds: 120),
      child: _HoverWrapper(
        lift: 8,
        child: _ProfileImage(
          profile.profileImage,
          size: isMobile ? 220 : (isCompact ? 240 : 280),
        ),
      ),
    );
    return SectionContainer(
      verticalPadding: isStacked ? (isMobile ? 40 : 56) : (isCompact ? 64 : 72),
      background: IgnorePointer(child: _HeroDotGridBackground(isDark: isDark)),
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
