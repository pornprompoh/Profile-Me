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
  ) => Material(
    elevation: 0,
    color: Theme.of(context).scaffoldBackgroundColor,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: child,
    ),
  );

  @override
  bool shouldRebuild(covariant _NavbarDelegate oldDelegate) =>
      oldDelegate.child != child;
}

class _Navbar extends StatelessWidget {
  const _Navbar({
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
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < LayoutTokens.mobileBreakpoint;
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
                const Icon(Icons.blur_circular, color: AppTheme.primary),
                const SizedBox(width: 8),
                if (!isMobile)
                  Text(
                    'Portfolio',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const Spacer(),
                if (width > 780)
                  ValueListenableBuilder<AppSection>(
                    valueListenable: state.activeSection,
                    builder: (context, active, _) => Row(
                      children: [
                        for (var i = 0; i < sections.length; i++)
                          TextButton(
                            onPressed: () => onNavigate(sections[i]),
                            style: TextButton.styleFrom(
                              foregroundColor: active == sections[i]
                                  ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppTheme.darkAccent
                                        : AppTheme.primary)
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                            child: Text(labels[i]),
                          ),
                      ],
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
                if (width >= 640)
                  ValueListenableBuilder<bool>(
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
                      label: Text(locale == AppLocale.th ? 'Resume' : 'Resume'),
                    ),
                  ),
                if (width <= 780)
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

