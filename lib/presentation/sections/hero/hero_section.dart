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
    final isMobile = width < LayoutTokens.mobileBreakpoint;
    final name = locale == AppLocale.th ? profile.names.th : profile.names.en;
    final role = locale == AppLocale.th ? profile.roles.th : profile.roles.en;
    final identity = _ScrollReveal(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            locale == AppLocale.th ? 'สวัสดีครับ ผมชื่อ' : 'Hello, I am',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: LayoutTokens.heroNameSize(context),
              height: 1.12,
              fontWeight: FontWeight.w800,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
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
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.center,
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
        ],
      ),
    );
    final image = _ScrollReveal(
      delay: const Duration(milliseconds: 120),
      child: _HoverWrapper(
        lift: 8,
        child: _ProfileImage(
          profile.profileImage,
          size: isMobile ? 220 : 280,
          onTap: () {},
        ),
      ),
    );
    return SectionContainer(
      verticalPadding: isMobile ? 44 : LayoutTokens.sectionPadding(context),
      background: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, .72, 1],
              colors: [
                Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: .30),
                Theme.of(
                  context,
                ).scaffoldBackgroundColor.withValues(alpha: .45),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [image, const SizedBox(height: 24), identity],
            )
          : Row(
              children: [
                Expanded(child: identity),
                const SizedBox(width: 48),
                Expanded(child: Center(child: image)),
              ],
            ),
    );
  }
}

