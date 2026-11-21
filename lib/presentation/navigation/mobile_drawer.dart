/// หน้าที่หลัก: แสดง Navigation Drawer สำหรับหน้าจอขนาดเล็ก
part of '../portfolio_ui.dart';

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({
    required this.state,
    required this.locale,
    required this.brandName,
    required this.onNavigate,
    required this.onPdf,
  });
  final AppState state;
  final AppLocale locale;
  final String brandName;
  final Future<void> Function(AppSection, [bool]) onNavigate;
  final Future<void> Function() onPdf;

  @override
  Widget build(BuildContext context) {
    final labels = AppStrings.navigationLabels(locale);
    return Drawer(
      width: MediaQuery.sizeOf(context).width.clamp(0.0, 320.0).toDouble(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LayoutTokens.drawerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavigate(AppSection.home, true);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _BrandLogo(
                                brandName: brandName,
                                iconSize: 24,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                          onTap: () {
                            Navigator.of(context).pop();
                            onNavigate(AppSection.values[i], true);
                          },
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
                      LocalStorageService.writeLocale(state.locale.value);
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
                      LocalStorageService.writeTheme(state.themeMode.value);
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
              ValueListenableBuilder<bool>(
                valueListenable: state.isGeneratingPdf,
                builder: (context, generating, _) => Center(
                  child: _ResumeButton(
                    locale: locale,
                    onPressed: onPdf,
                    isGenerating: generating,
                    height: LayoutTokens.touchTarget,
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
