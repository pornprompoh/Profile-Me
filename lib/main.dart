import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/state/app_state.dart';
import 'core/storage/browser_storage.dart';
import 'core/theme/app_theme.dart';
import 'data/models/content_models.dart';
import 'data/repositories/content_repository.dart';
import 'presentation/modals/all_projects_modal.dart';
import 'core/theme/layout_tokens.dart';
import 'presentation/widgets/section_widgets.dart';
import 'presentation/widgets/project_link_button.dart';
import 'services/pdf/resume_pdf_service.dart';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState(
      locale: BrowserStorage.initialLocale(),
      themeMode: BrowserStorage.initialThemeMode(),
    );
    return _StateScope(
      state: state,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: state.themeMode,
        builder: (context, mode, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Profile Portfolio',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: const PortfolioPage(),
        ),
      ),
    );
  }
}

class _StateScope extends InheritedWidget {
  const _StateScope({required this.state, required super.child});
  final AppState state;

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_StateScope>()!.state;

  @override
  bool updateShouldNotify(_StateScope oldWidget) => state != oldWidget.state;
}

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final repository = ContentRepository();
  final scrollController = ScrollController();
  final keys = {
    AppSection.home: GlobalKey(),
    AppSection.about: GlobalKey(),
    AppSection.timeline: GlobalKey(),
    AppSection.projects: GlobalKey(),
    AppSection.contact: GlobalKey(),
  };
  Profile? profile;
  List<Project> projects = [];
  Links? links;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollSpy);
    _load();
  }

  Future<void> _load() async {
    try {
      final loadedProfile = await repository.loadProfile();
      final loadedProjects = await repository.loadProjects();
      final loadedLinks = await repository.loadLinks();
      if (!mounted) return;
      setState(() {
        profile = loadedProfile;
        projects = loadedProjects;
        links = loadedLinks;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  void _scrollSpy() {
    final state = _StateScope.of(context);
    state.showBackToTop.value = scrollController.offset > 350;
    AppSection closest = AppSection.home;
    var distance = double.infinity;
    for (final entry in keys.entries) {
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final position = box.localToGlobal(Offset.zero).dy;
      final value = (position - 120).abs();
      if (value < distance) {
        distance = value;
        closest = entry.key;
      }
    }
    if (state.activeSection.value != closest) {
      state.activeSection.value = closest;
    }
  }

  Future<void> _scrollTo(AppSection section) async {
    final state = _StateScope.of(context);
    state.activeSection.value = section;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    final targetContext = keys[section]?.currentContext;
    final box = targetContext?.findRenderObject() as RenderBox?;
    if (box != null && scrollController.hasClients) {
      final top =
          box.localToGlobal(Offset.zero).dy +
          scrollController.offset -
          LayoutTokens.navbarHeight -
          8;
      final maxScroll = scrollController.position.maxScrollExtent;
      await scrollController.animateTo(
        top.clamp(0.0, maxScroll),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _StateScope.of(context);
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (profile == null || links == null) {
      return Scaffold(
        body: Center(
          child: Text(
            state.locale.value == AppLocale.th
                ? 'ไม่สามารถโหลดข้อมูลได้'
                : 'Unable to load content',
          ),
        ),
      );
    }
    return ValueListenableBuilder<AppLocale>(
      valueListenable: state.locale,
      builder: (context, locale, _) => Scaffold(
        endDrawer: _MobileDrawer(
          state: state,
          locale: locale,
          onNavigate: _scrollTo,
          onPdf: () => _downloadPdf(state, locale),
        ),
        body: Stack(
          children: [
            CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _NavbarDelegate(
                    minHeight: 72,
                    maxHeight: 72,
                    child: _Navbar(
                      state: state,
                      locale: locale,
                      onNavigate: _scrollTo,
                      onPdf: () => _downloadPdf(state, locale),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    _Section(
                      key: keys[AppSection.home],
                      child: _Hero(
                        profile!,
                        locale,
                        onProjects: () {
                          _scrollTo(AppSection.projects);
                        },
                        onContact: () {
                          _scrollTo(AppSection.contact);
                        },
                      ),
                    ),
                    _Section(
                      key: keys[AppSection.about],
                      child: _About(profile!, locale),
                    ),
                    _Section(
                      key: keys[AppSection.timeline],
                      child: _Timeline(profile!, locale),
                    ),
                    _Section(
                      key: keys[AppSection.projects],
                      child: _Projects(projects, links!, state, locale),
                    ),
                    _Section(
                      key: keys[AppSection.contact],
                      child: _Contact(profile!, links!, state, locale),
                    ),
                    _Footer(profile: profile!, locale: locale),
                  ]),
                ),
              ],
            ),
            ValueListenableBuilder<bool>(
              valueListenable: state.showBackToTop,
              builder: (context, visible, _) => Positioned(
                right: 24,
                bottom: 24,
                child: AnimatedOpacity(
                  opacity: visible ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: AnimatedScale(
                    scale: visible ? 1 : .7,
                    duration: const Duration(milliseconds: 220),
                    child: _HoverWrapper(
                      child: FloatingActionButton(
                        onPressed: visible
                            ? () => scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeInOutCubic,
                              )
                            : null,
                        tooltip: locale == AppLocale.th
                            ? 'กลับขึ้นด้านบน'
                            : 'Back to top',
                        child: const Icon(Icons.keyboard_arrow_up),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf(AppState state, AppLocale locale) async {
    if (profile == null || links == null) return;
    state.isGeneratingPdf.value = true;
    try {
      await ResumePdfService().download(profile!, links!, projects, locale);
    } finally {
      state.isGeneratingPdf.value = false;
    }
  }
}

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
                    BrowserStorage.write(
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
                    BrowserStorage.write(
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
                      BrowserStorage.write(
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
                      BrowserStorage.write(
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

class _Section extends StatelessWidget {
  const _Section({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: double.infinity, child: child);
}

class _ScrollReveal extends StatefulWidget {
  const _ScrollReveal({required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final animation = CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) => Opacity(
      opacity: animation.value,
      child: Transform.translate(
        offset: Offset(0, 18 * (1 - animation.value)),
        child: child,
      ),
    ),
    child: widget.child,
  );
}

class _HoverWrapper extends StatefulWidget {
  const _HoverWrapper({required this.child, this.lift = 6});
  final Widget child;
  final double lift;

  @override
  State<_HoverWrapper> createState() => _HoverWrapperState();
}

class _HoverWrapperState extends State<_HoverWrapper> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    child: AnimatedScale(
      scale: hovered ? 1.02 : 1,
      duration: const Duration(milliseconds: 180),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, hovered ? -widget.lift : 0, 0),
        child: widget.child,
      ),
    ),
  );
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage(this.path, {required this.size, required this.onTap});
  final String path;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: path.isEmpty
        ? null
        : () => showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) => _Lightbox(images: [path]),
          ),
    borderRadius: BorderRadius.circular(size / 2),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.sky, width: 8),
      ),
      child: ClipOval(
        child: path.isNotEmpty
            ? Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const ColoredBox(color: AppTheme.sky),
              )
            : const ColoredBox(color: AppTheme.sky),
      ),
    ),
  );
}

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
            locale == AppLocale.th ? 'สวัสดี ผมคือ' : 'Hello, I am',
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

class _About extends StatelessWidget {
  const _About(this.profile, this.locale);
  final Profile profile;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < LayoutTokens.mobileBreakpoint;
    return SectionContainer(
      child: _ScrollReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: locale == AppLocale.th ? 'เกี่ยวกับฉัน' : 'About Me',
              subtitle: locale == AppLocale.th
                  ? 'ประวัติและจุดสนใจ'
                  : 'Background and interests',
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) => isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale == AppLocale.th
                              ? profile.bio.th
                              : profile.bio.en,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(height: 1.75),
                        ),
                        const SizedBox(height: 20),
                        _AboutFacts(profile: profile, locale: locale),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            locale == AppLocale.th
                                ? profile.bio.th
                                : profile.bio.en,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(height: 1.75),
                          ),
                        ),
                        const SizedBox(width: 36),
                        Expanded(
                          flex: 2,
                          child: _AboutFacts(profile: profile, locale: locale),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
            for (final group in profile.skillGroups)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale == AppLocale.th ? group.title.th : group.title.en,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final skill in group.skills)
                          Chip(
                            label: Text(skill),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AboutFacts extends StatelessWidget {
  const _AboutFacts({required this.profile, required this.locale});
  final Profile profile;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.primaryContainer.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? .28 : .55,
    );
    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(LayoutTokens.cardRadius),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cake_outlined),
              const SizedBox(width: 10),
              Text(
                '${locale == AppLocale.th ? 'อายุ' : 'Age'} ${profile.age}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mail_outline),
              const SizedBox(width: 10),
              Expanded(
                child: SelectableText(
                  profile.email,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.subtitle);
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) =>
      SectionHeader(title: title, subtitle: subtitle);
}

class _Timeline extends StatelessWidget {
  const _Timeline(this.profile, this.locale);
  final Profile profile;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: locale == AppLocale.th
                ? 'ประวัติและประสบการณ์'
                : 'Education & Experience',
            subtitle: locale == AppLocale.th
                ? 'เส้นทางการเรียนรู้และการทำงาน'
                : 'Learning and career journey',
          ),
          const SizedBox(height: 32),
          for (var i = 0; i < profile.education.length; i++)
            _TimelineItem(
              period: profile.education[i].period,
              title: locale == AppLocale.th
                  ? profile.education[i].field.th
                  : profile.education[i].field.en,
              organization: locale == AppLocale.th
                  ? profile.education[i].institution.th
                  : profile.education[i].institution.en,
              details: locale == AppLocale.th
                  ? profile.education[i].details.th
                  : profile.education[i].details.en,
              education: true,
              delay: Duration(milliseconds: i * 80),
            ),
          for (var i = 0; i < profile.experience.length; i++)
            _TimelineItem(
              period: profile.experience[i].period,
              title: locale == AppLocale.th
                  ? profile.experience[i].role.th
                  : profile.experience[i].role.en,
              organization: locale == AppLocale.th
                  ? profile.experience[i].organization.th
                  : profile.experience[i].organization.en,
              details: locale == AppLocale.th
                  ? profile.experience[i].details.th
                  : profile.experience[i].details.en,
              education: false,
              delay: Duration(
                milliseconds: (i + profile.education.length) * 80,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.period,
    required this.title,
    required this.organization,
    required this.details,
    required this.education,
    required this.delay,
  });
  final String period;
  final String title;
  final String organization;
  final String details;
  final bool education;
  final Duration delay;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    delay: delay,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  education ? Icons.school : Icons.work,
                  size: 17,
                  color: Colors.white,
                ),
              ),
              Container(width: 3, height: 120, color: AppTheme.sky),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _HoverWrapper(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (period.isNotEmpty)
                      Chip(
                        label: Text(period),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                      ),
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (organization.isNotEmpty)
                      Text(
                        organization,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.primary),
                      ),
                    if (details.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(details),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Projects extends StatefulWidget {
  const _Projects(this.projects, this.links, this.state, this.locale);
  final List<Project> projects;
  final Links links;
  final AppState state;
  final AppLocale locale;

  @override
  State<_Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<_Projects> {
  String _categoryInCurrentLocale(String selected) {
    if (selected == 'all') return selected;
    for (final project in widget.projects) {
      if (project.category.th == selected || project.category.en == selected) {
        return widget.locale == AppLocale.th
            ? project.category.th
            : project.category.en;
      }
    }
    return 'all';
  }

  @override
  Widget build(BuildContext context) {
    final categories = {
      for (final project in widget.projects)
        widget.locale == AppLocale.th
            ? project.category.th
            : project.category.en,
    }.where((category) => category.isNotEmpty).toList()..sort();
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: widget.locale == AppLocale.th ? 'ผลงาน' : 'Projects',
            subtitle: widget.locale == AppLocale.th
                ? 'เลือกดูผลงานตามหมวดหมู่'
                : 'Browse selected work',
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<String>(
            valueListenable: widget.state.selectedCategory,
            builder: (context, selected, _) {
              final currentSelection = _categoryInCurrentLocale(selected);
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(
                      widget.locale == AppLocale.th ? 'ทั้งหมด' : 'All',
                    ),
                    selected: currentSelection == 'all',
                    onSelected: (_) =>
                        widget.state.selectedCategory.value = 'all',
                  ),
                  for (final category in categories)
                    ChoiceChip(
                      label: Text(category),
                      selected: currentSelection == category,
                      onSelected: (_) =>
                          widget.state.selectedCategory.value = category,
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<String>(
            valueListenable: widget.state.selectedCategory,
            builder: (context, selected, _) {
              final currentSelection = _categoryInCurrentLocale(selected);
              final filtered = sortProjectsByFeaturedAndUpdated(
                widget.projects.where((project) {
                  final category = widget.locale == AppLocale.th
                      ? project.category.th
                      : project.category.en;
                  return currentSelection == 'all' ||
                      category == currentSelection;
                }),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = LayoutTokens.projectColumnCount(width);
                      final visibleLimit = LayoutTokens.projectVisibleLimit(
                        width,
                      );
                      final visibleProjects = filtered
                          .take(visibleLimit)
                          .toList();
                      final cardHeight = width < LayoutTokens.mobileBreakpoint
                          ? 560.0
                          : (width <= LayoutTokens.tabletBreakpoint
                                ? 560.0
                                : 540.0);
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 18,
                          mainAxisExtent: cardHeight,
                        ),
                        itemCount: visibleProjects.length,
                        itemBuilder: (context, i) => _ScrollReveal(
                          delay: Duration(milliseconds: i * 70),
                          child: _ProjectCard(
                            project: visibleProjects[i],
                            links: widget.links,
                            locale: widget.locale,
                          ),
                        ),
                      );
                    },
                  ),
                  Builder(
                    builder: (context) {
                      final width = MediaQuery.sizeOf(context).width;
                      final visibleLimit = LayoutTokens.projectVisibleLimit(
                        width,
                      );
                      if (filtered.length < visibleLimit) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: Center(
                          child: FilledButton.icon(
                            onPressed: () => showGeneralDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: MaterialLocalizations.of(
                                context,
                              ).modalBarrierDismissLabel,
                              barrierColor: Colors.black54,
                              transitionDuration: const Duration(
                                milliseconds: 240,
                              ),
                              pageBuilder: (context, animation, secondary) =>
                                  AllProjectsModal(
                                    projects: sortProjectsByFeaturedAndUpdated(
                                      widget.projects,
                                    ),
                                    initialCategory: currentSelection,
                                    locale: widget.locale,
                                    projectCardBuilder: (project) =>
                                        _ProjectCard(
                                          project: project,
                                          links: widget.links,
                                          locale: widget.locale,
                                        ),
                                  ),
                              transitionBuilder:
                                  (context, animation, secondary, child) {
                                    final curve = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                      reverseCurve: Curves.easeInCubic,
                                    );
                                    return FadeTransition(
                                      opacity: curve,
                                      child: ScaleTransition(
                                        scale: Tween<double>(
                                          begin: .96,
                                          end: 1,
                                        ).animate(curve),
                                        child: child,
                                      ),
                                    );
                                  },
                            ),
                            icon: const Icon(Icons.grid_view_rounded),
                            label: Text(
                              widget.locale == AppLocale.th
                                  ? 'ดูผลงานทั้งหมด (${filtered.length} ผลงาน)'
                                  : 'View All Projects (${filtered.length})',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.links,
    required this.locale,
  });
  final Project project;
  final Links links;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final githubLink = links.projectLinks.cast<ProjectLink?>().firstWhere(
      (link) =>
          link != null &&
          link.projectId == project.id &&
          link.type.toLowerCase() == 'github',
      orElse: () => null,
    );
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppTheme.darkAccent
        : AppTheme.primary;
    return _HoverWrapper(
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LayoutTokens.cardRadius),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: () => showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) =>
                _ProjectModal(project: project, links: links, locale: locale),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: project.images.isNotEmpty
                    ? Image.asset(
                        project.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const ColoredBox(color: AppTheme.sky),
                      )
                    : const ColoredBox(color: AppTheme.sky),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(LayoutTokens.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale == AppLocale.th
                            ? project.category.th
                            : project.category.en,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: accent),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        locale == AppLocale.th
                            ? project.title.th
                            : project.title.en,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: LayoutTokens.cardTitleSize(context),
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        locale == AppLocale.th
                            ? project.summary.th
                            : project.summary.en,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final tag in project.tags.take(4))
                            Chip(
                              label: Text(tag),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      if (githubLink != null) ...[
                        const SizedBox(height: 10),
                        ProjectLinkButton(
                          link: githubLink,
                          locale: locale,
                          compact: true,
                        ),
                      ],
                    ],
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

class _ProjectModal extends StatefulWidget {
  const _ProjectModal({
    required this.project,
    required this.links,
    required this.locale,
  });
  final Project project;
  final Links links;
  final AppLocale locale;

  @override
  State<_ProjectModal> createState() => _ProjectModalState();
}

class _ProjectModalState extends State<_ProjectModal> {
  final pageController = PageController();
  var index = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.project.images;
    final projectLinks = widget.links.projectLinks
        .where((link) => link.projectId == widget.project.id)
        .toList();
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LayoutTokens.modalRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.locale == AppLocale.th
                              ? widget.project.title.th
                              : widget.project.title.en,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (images.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: PageView.builder(
                                  controller: pageController,
                                  itemCount: images.length,
                                  onPageChanged: (value) =>
                                      setState(() => index = value),
                                  itemBuilder: (context, i) => InkWell(
                                    onTap: () => showDialog<void>(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (_) => _Lightbox(
                                        images: images,
                                        initialIndex: i,
                                      ),
                                    ),
                                    child: Image.asset(
                                      images[i],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const ColoredBox(color: AppTheme.sky),
                                    ),
                                  ),
                                ),
                              ),
                              if (MediaQuery.sizeOf(context).width > 700)
                                Positioned(
                                  left: 8,
                                  child: IconButton.filledTonal(
                                    onPressed: () =>
                                        pageController.previousPage(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        ),
                                    icon: const Icon(Icons.chevron_left),
                                  ),
                                ),
                              if (MediaQuery.sizeOf(context).width > 700)
                                Positioned(
                                  right: 8,
                                  child: IconButton.filledTonal(
                                    onPressed: () => pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    ),
                                    icon: const Icon(Icons.chevron_right),
                                  ),
                                ),
                              Positioned(
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${index + 1} / ${images.length}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        widget.locale == AppLocale.th
                            ? widget.project.description.th
                            : widget.project.description.en,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.locale == AppLocale.th
                            ? 'จุดเด่น'
                            : 'Highlights',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      for (final highlight in widget.project.highlights)
                        ListTile(
                          dense: true,
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text(
                            widget.locale == AppLocale.th
                                ? highlight.th
                                : highlight.en,
                          ),
                        ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in widget.project.tags)
                            Chip(label: Text(tag)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final link in projectLinks)
                            ProjectLinkButton(
                              link: link,
                              locale: widget.locale,
                            ),
                        ],
                      ),
                    ],
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

class _Lightbox extends StatefulWidget {
  const _Lightbox({required this.images, this.initialIndex = 0});
  final List<String> images;
  final int initialIndex;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late final controller = PageController(initialPage: widget.initialIndex);
  late var index = widget.initialIndex;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: EdgeInsets.zero,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: const Color(0xE0000000)),
          GestureDetector(
            onTap: () {},
            child: PageView.builder(
              controller: controller,
              itemCount: widget.images.length,
              onPageChanged: (value) => setState(() => index = value),
              itemBuilder: (context, i) => InteractiveViewer(
                minScale: .5,
                maxScale: 5,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Image.asset(widget.images[i], fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: IconButton.filled(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),
          if (widget.images.length > 1) ...[
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              child: IconButton.filledTonal(
                onPressed: () => controller.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                icon: const Icon(Icons.chevron_left),
              ),
            ),
            Positioned(
              right: 24,
              top: 0,
              bottom: 0,
              child: IconButton.filledTonal(
                onPressed: () => controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                icon: const Icon(Icons.chevron_right),
              ),
            ),
          ],
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${index + 1} / ${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Contact extends StatelessWidget {
  const _Contact(this.profile, this.links, this.state, this.locale);
  final Profile profile;
  final Links links;
  final AppState state;
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
    return SectionContainer(
      child: _ScrollReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              locale == AppLocale.th ? 'ติดต่อ' : 'Contact',
              locale == AppLocale.th
                  ? 'ช่องทางสำหรับพูดคุยและทำงานร่วมกัน'
                  : 'Let us connect and build together',
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (profile.email.isNotEmpty)
                  FilledButton.icon(
                    onPressed: () => _copyEmail(context),
                    icon: const Icon(Icons.copy),
                    label: Text(profile.email),
                  ),
                for (final link in links.socialLinks)
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(link.url),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: Icon(
                      link.icon.toLowerCase().contains('github')
                          ? Icons.code
                          : link.icon.toLowerCase().contains('linkedin')
                          ? Icons.work
                          : Icons.link,
                    ),
                    label: Text(link.label),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.profile, required this.locale});
  final Profile profile;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final name = locale == AppLocale.th ? profile.names.th : profile.names.en;
    return SectionContainer(
      verticalPadding: 18,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        padding: const EdgeInsets.only(top: 18),
        child: Text(
          '© ${DateTime.now().year} $name. ${locale == AppLocale.th ? 'สงวนลิขสิทธิ์' : 'All rights reserved.'}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
