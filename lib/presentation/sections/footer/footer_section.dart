// หน้าที่หลัก: รวมช่องทางติดต่อและข้อความลิขสิทธิ์ไว้ใน Footer
part of '../../../main.dart';

class _Footer extends StatelessWidget {
  const _Footer({
    required this.profile,
    required this.links,
    required this.locale,
  });

  final Profile profile;
  final Links links;
  final AppLocale locale;

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profile.email));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          locale == AppLocale.th
              ? 'คัดลอกอีเมลแล้ว'
              : 'Email copied to clipboard',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile =
        MediaQuery.sizeOf(context).width < LayoutTokens.mobileBreakpoint;
    final name = locale == AppLocale.th ? profile.names.th : profile.names.en;
    final copyright = locale == AppLocale.th
        ? '© ${DateTime.now().year} $name สงวนลิขสิทธิ์'
        : '© ${DateTime.now().year} $name. All rights reserved.';
    final contactIcons = <Widget>[
      if (profile.email.isNotEmpty)
        _contactIcon(
          context,
          tooltip: AppStrings.emailTooltip(locale, profile.email),
          icon: const Icon(Icons.email_outlined),
          onPressed: () => _copyEmail(context),
        ),
      for (final link in links.socialLinks)
        _contactIcon(
          context,
          tooltip: link.label,
          icon: BrandIcon(name: link.icon, size: 18),
          onPressed: () => launchUrl(
            Uri.parse(link.url),
            mode: LaunchMode.externalApplication,
          ),
        ),
    ];

    return SectionContainer(
      verticalPadding: isMobile ? 28 : 30,
      background: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.darkOceanDeep, AppColors.darkOceanMid]
                  : [AppColors.lightOceanDeep, AppColors.lightOceanMid],
            ),
          ),
        ),
      ),
      child: _ScrollReveal(
        child: isMobile
            ? Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: contactIcons,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: .12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    copyright,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .76),
                      fontSize: 13,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      copyright,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .76),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Wrap(spacing: 12, children: contactIcons),
                ],
              ),
      ),
    );
  }

  Widget _contactIcon(
    BuildContext context, {
    required String tooltip,
    required Widget icon,
    required Future<void> Function() onPressed,
  }) => Tooltip(
    message: tooltip,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .06),
              border: Border.all(color: Colors.white.withValues(alpha: .22)),
            ),
            child: IconTheme(
              data: const IconThemeData(color: Colors.white, size: 18),
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    ),
  );
}
