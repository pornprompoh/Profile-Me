// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../../main.dart';

class _NavbarDelegate extends SliverPersistentHeaderDelegate {
  _NavbarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final brightness = Theme.of(context).brightness;
    final accent = AppTheme.navbarAccent(brightness);
    return Material(
      elevation: 0,
      color: AppTheme.navbarSurface(brightness),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: accent.withValues(alpha: .72), width: 2),
            bottom: BorderSide(color: accent.withValues(alpha: .24), width: 1),
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _NavbarDelegate oldDelegate) =>
      oldDelegate.child != child;
}

class _Navbar extends StatelessWidget {
  const _Navbar({
    required this.state,
    required this.locale,
    required this.onNavigate,
    required this.socialLinks,
  });
  final AppState state;
  final AppLocale locale;
  final Future<void> Function(AppSection) onNavigate;
  final List<SocialLink> socialLinks;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < LayoutTokens.mobileBreakpoint;
    final showFullNavigation = width >= 900;
    final showSocialLinks = width >= 1100;
    final accent = AppTheme.navbarAccent(Theme.of(context).brightness);
    final labels = locale == AppLocale.th
        ? const ['หน้าแรก', 'เกี่ยวกับฉัน', 'ประวัติ', 'ผลงาน', 'ติดต่อ']
        : const ['Home', 'About', 'Timeline', 'Projects', 'Contact'];
    final sections = AppSection.values;
    return SizedBox(
      height: LayoutTokens.navbarHeight,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LayoutTokens.maxContentWidth,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: LayoutTokens.horizontalPadding(context),
            ),
            child: Row(
              children: [
                Icon(Icons.blur_circular, color: accent),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  Text(
                    'PORTFOLIO',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
                if (showFullNavigation) const SizedBox(width: 18),
                if (showFullNavigation)
                  Expanded(
                    child: Center(
                      child: ValueListenableBuilder<AppSection>(
                        valueListenable: state.activeSection,
                        builder: (context, active, _) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < sections.length; i++)
                              TextButton(
                                onPressed: () => onNavigate(sections[i]),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(0, 44),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                  ),
                                  foregroundColor: active == sections[i]
                                      ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppTheme.darkAccent
                                            : AppTheme.primary)
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                                child: Text(
                                  locale == AppLocale.en
                                      ? labels[i].toUpperCase()
                                      : labels[i],
                                  style: TextStyle(
                                    fontSize: locale == AppLocale.en ? 11 : 13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: locale == AppLocale.en
                                        ? 1
                                        : 0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!showFullNavigation) const Spacer(),
                if (showSocialLinks)
                  for (final link in socialLinks)
                    IconButton(
                      tooltip: link.label,
                      onPressed: () async {
                        await launchUrl(
                          Uri.parse(link.url),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: BrandIcon(name: link.icon, size: 20),
                      constraints: const BoxConstraints.tightFor(
                        width: LayoutTokens.touchTarget,
                        height: LayoutTokens.touchTarget,
                      ),
                    ),
                IconButton(
                  tooltip: locale == AppLocale.th
                      ? 'เปลี่ยนภาษา'
                      : 'Change language',
                  onPressed: () {
                    state.locale.value = locale == AppLocale.th
                        ? AppLocale.en
                        : AppLocale.th;
                    LocalStorageService.write(
                      'profile_locale',
                      state.locale.value == AppLocale.th ? 'th' : 'en',
                    );
                  },
                  icon: Text(
                    locale == AppLocale.th ? 'EN' : 'TH',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: locale == AppLocale.th ? 'สลับธีม' : 'Toggle theme',
                  onPressed: () {
                    state.themeMode.value =
                        state.themeMode.value == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark;
                    LocalStorageService.write(
                      'profile_theme',
                      state.themeMode.value == ThemeMode.dark
                          ? 'dark'
                          : 'light',
                    );
                  },
                  icon: Icon(
                    state.themeMode.value == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                ),
                if (!showFullNavigation)
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: Scaffold.of(context).openEndDrawer,
                      icon: const Icon(Icons.menu),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({
    required this.state,
    required this.locale,
    required this.onNavigate,
    required this.onPdf,
  });
  final AppState state;
  final AppLocale locale;
  final Future<void> Function(AppSection) onNavigate;
  final Future<void> Function() onPdf;

  @override
  Widget build(BuildContext context) {
    final labels = locale == AppLocale.th
        ? const ['หน้าแรก', 'เกี่ยวกับฉัน', 'ประวัติ', 'ผลงาน', 'ติดต่อ']
        : const ['Home', 'About', 'Timeline', 'Projects', 'Contact'];
    return Drawer(
      width: 320,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LayoutTokens.drawerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.blur_circular, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Portfolio',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ValueListenableBuilder<AppSection>(
                  valueListenable: state.activeSection,
                  builder: (context, active, _) => ListView(
                    children: [
                      for (var i = 0; i < AppSection.values.length; i++)
                        ListTile(
                          minTileHeight: LayoutTokens.touchTarget,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              LayoutTokens.controlRadius,
                            ),
                          ),
                          selected: active == AppSection.values[i],
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: .45),
                          title: Text(
                            labels[i],
                            style: TextStyle(
                              color: active == AppSection.values[i]
                                  ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppTheme.darkAccent
                                        : AppTheme.primary)
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: active == AppSection.values[i]
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          onTap: () => onNavigate(AppSection.values[i]),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      state.locale.value = locale == AppLocale.th
                          ? AppLocale.en
                          : AppLocale.th;
                      LocalStorageService.write(
                        'profile_locale',
                        state.locale.value == AppLocale.th ? 'th' : 'en',
                      );
                    },
                    icon: Text(
                      locale == AppLocale.th ? 'EN' : 'TH',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: LayoutTokens.touchTarget,
                      minHeight: LayoutTokens.touchTarget,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      state.themeMode.value =
                          state.themeMode.value == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                      LocalStorageService.write(
                        'profile_theme',
                        state.themeMode.value == ThemeMode.dark
                            ? 'dark'
                            : 'light',
                      );
                    },
                    icon: Icon(
                      state.themeMode.value == ThemeMode.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ValueListenableBuilder<bool>(
                  valueListenable: state.isGeneratingPdf,
                  builder: (context, generating, _) => FilledButton.icon(
                    onPressed: generating ? null : onPdf,
                    icon: generating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: const Text('Resume PDF'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
