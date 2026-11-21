/// หน้าที่หลัก: แสดง Navbar แบบ Sticky พร้อมภาษา ธีม และปุ่ม Resume
part of '../portfolio_ui.dart';

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
            bottom: BorderSide(color: accent.withValues(alpha: .16), width: 1),
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
    required this.brandName,
    required this.onNavigate,
    required this.onPdf,
    super.key,
  });
  final AppState state;
  final AppLocale locale;
  final String brandName;
  final Future<void> Function(AppSection, [bool]) onNavigate;
  final Future<void> Function() onPdf;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showFullNavigation = width >= 900;
    final controlSize = width < 420 ? 40.0 : LayoutTokens.touchTarget;
    final accent = AppTheme.navbarAccent(Theme.of(context).brightness);
    final labels = AppStrings.navigationLabels(locale);
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
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Tooltip(
                    message: brandName,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onNavigate(AppSection.home);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 9,
                          ),
                          child: _BrandLogo(
                            brandName: brandName,
                            iconSize: width < LayoutTokens.mobileBreakpoint
                                ? 24
                                : 30,
                            textStyle: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .2,
                                  color: accent,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
                              Builder(
                                builder: (context) {
                                  final isActive = active == sections[i];
                                  final accent =
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppTheme.darkAccent
                                      : AppTheme.primary;
                                  return TextButton(
                                    onPressed: () => onNavigate(sections[i]),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(0, 44),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      foregroundColor: isActive
                                          ? accent
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      backgroundColor: isActive
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                                .withValues(alpha: .28)
                                          : null,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      locale == AppLocale.en
                                          ? labels[i].toUpperCase()
                                          : labels[i],
                                      style: TextStyle(
                                        fontSize: locale == AppLocale.en
                                            ? 13
                                            : 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: locale == AppLocale.en
                                            ? .6
                                            : 0,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!showFullNavigation) const Spacer(),
                IconButton(
                  tooltip: AppStrings.changeLanguageTooltip(locale),
                  onPressed: () {
                    state.locale.value = locale == AppLocale.th
                        ? AppLocale.en
                        : AppLocale.th;
                    LocalStorageService.writeLocale(state.locale.value);
                  },
                  icon: Text(
                    locale == AppLocale.th ? 'EN' : 'TH',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: controlSize,
                    height: controlSize,
                  ),
                ),
                IconButton(
                  tooltip: AppStrings.toggleThemeTooltip(locale),
                  onPressed: () {
                    state.themeMode.value =
                        state.themeMode.value == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark;
                    LocalStorageService.writeTheme(state.themeMode.value);
                  },
                  icon: Icon(
                    state.themeMode.value == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(
                    width: controlSize,
                    height: controlSize,
                  ),
                ),
                if (showFullNavigation) ...[
                  const SizedBox(width: 2),
                  ValueListenableBuilder<bool>(
                    valueListenable: state.isGeneratingPdf,
                    builder: (context, generating, _) => _ResumeButton(
                      locale: locale,
                      onPressed: onPdf,
                      isGenerating: generating,
                      height: controlSize,
                    ),
                  ),
                ],
                if (!showFullNavigation)
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: Scaffold.of(context).openEndDrawer,
                      icon: const Icon(Icons.menu),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints.tightFor(
                        width: controlSize,
                        height: controlSize,
                      ),
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

class _ResumeButton extends StatelessWidget {
  const _ResumeButton({
    required this.locale,
    required this.onPressed,
    required this.isGenerating,
    this.height = LayoutTokens.touchTarget,
  });

  final AppLocale locale;
  final Future<void> Function() onPressed;
  final bool isGenerating;
  final double height;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: AppStrings.resumeTooltip(locale),
    child: OutlinedButton(
      onPressed: isGenerating ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        side: BorderSide(
          color: AppTheme.navbarAccent(
            Theme.of(context).brightness,
          ).withValues(alpha: .42),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: Size(0, height),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const StadiumBorder(),
      ),
      child: isGenerating
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Resume'),
    ),
  );
}
