// หน้าที่หลัก: จัดการเลื่อนหน้า และเชื่อม Scroll Spy ของ Portfolio
part of '../../main.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  static const double scrollNoOpTolerance = 10;
  static const Duration scrollDuration = Duration(milliseconds: 550);

  final repository = ContentRepository();
  final scrollController = ScrollController();
  final revealMetricsRevision = ValueNotifier<int>(0);
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final navbarKey = GlobalKey();
  final headerKeys = {
    AppSection.about: GlobalKey(),
    AppSection.timeline: GlobalKey(),
    AppSection.projects: GlobalKey(),
  };
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
  bool _isProgrammaticScrolling = false;
  int _scrollAnimationToken = 0;

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

  double _actualNavbarHeight() {
    final box = navbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) return box.size.height;
    return LayoutTokens.navbarHeight;
  }

  // breathingGap 20px บนมือถือและ 24px บน tablet/desktop
  double _breathingGap(BuildContext context) =>
      MediaQuery.sizeOf(context).width < LayoutTokens.mobileBreakpoint
      ? 20
      : 24;

  double _scrollSpyLine(BuildContext context) =>
      _actualNavbarHeight() + _breathingGap(context);

  void _interruptProgrammaticScroll() {
    if (!_isProgrammaticScrolling) return;
    // Pointer signal หรือ touch drag ยกเลิก token เพื่อปลด Scroll Lock
    _scrollAnimationToken++;
    _isProgrammaticScrolling = false;
    _scrollSpy();
  }

  void _scrollSpy() {
    if (_isProgrammaticScrolling) return;
    final state = _StateScope.of(context);
    AppSection closest = AppSection.home;
    var distance = double.infinity;
    final spyLine = _scrollSpyLine(context);

    for (final entry in keys.entries) {
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final position = box.localToGlobal(Offset.zero).dy;
      final value = (position - spyLine).abs();
      if (value < distance) {
        distance = value;
        closest = entry.key;
      }
    }

    for (final entry in headerKeys.entries) {
      final box = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final value = (box.localToGlobal(Offset.zero).dy - spyLine).abs();
      if (value < distance) {
        distance = value;
        closest = entry.key;
      }
    }

    if (state.activeSection.value != closest) {
      state.activeSection.value = closest;
    }
  }

  double? _targetOffset(AppSection section, BuildContext context) {
    if (!scrollController.hasClients) return null;
    if (section == AppSection.home) return 0;
    if (section == AppSection.contact) {
      return scrollController.position.maxScrollExtent;
    }

    final headerKey = headerKeys[section];
    if (headerKey != null) {
      final box = headerKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final top = box.localToGlobal(Offset.zero).dy;
        final target =
            top +
            scrollController.offset -
            _actualNavbarHeight() -
            _breathingGap(context);
        return target.clamp(0, scrollController.position.maxScrollExtent);
      }
    }

    final box = keys[section]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final top =
        box.localToGlobal(Offset.zero).dy +
        scrollController.offset -
        _actualNavbarHeight() -
        _breathingGap(context);
    return top.clamp(0, scrollController.position.maxScrollExtent);
  }

  Future<void> _scrollTo(AppSection section, [bool fromDrawer = false]) async {
    final state = _StateScope.of(context);
    state.activeSection.value = section;

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    if (fromDrawer && !MediaQuery.disableAnimationsOf(context)) {
      // ปิด Drawer แล้วรอ 150ms ก่อนเลื่อนเพื่อไม่ให้จอมือถือกระตุก
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!mounted || !scrollController.hasClients) return;
    }

    final targetOffset = _targetOffset(section, context);
    if (targetOffset == null) return;

    // no-op: ไม่สั่ง jump/animate และไม่เปิดล็อกหากห่างเป้าหมายไม่เกิน 10px
    if ((scrollController.offset - targetOffset).abs() <= scrollNoOpTolerance) {
      state.activeSection.value = section;
      return;
    }

    if (MediaQuery.disableAnimationsOf(context)) {
      _scrollAnimationToken++;
      _isProgrammaticScrolling = false;
      scrollController.jumpTo(targetOffset);
      state.activeSection.value = section;
      return;
    }

    final token = ++_scrollAnimationToken;
    _isProgrammaticScrolling = true;
    try {
      await scrollController.animateTo(
        targetOffset,
        duration: scrollDuration,
        curve: Curves.easeInOutCubic,
      );
    } finally {
      if (token == _scrollAnimationToken) {
        _isProgrammaticScrolling = false;
        state.activeSection.value = section;
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollSpy);
    scrollController.dispose();
    revealMetricsRevision.dispose();
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
        key: scaffoldKey,
        endDrawer: _MobileDrawer(
          state: state,
          locale: locale,
          brandName: profile!.englishFirstName,
          onNavigate: _scrollTo,
          onPdf: () => _downloadPdf(state, locale),
        ),
        body: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              _interruptProgrammaticScroll();
            }
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is UserScrollNotification &&
                  notification.direction != ScrollDirection.idle) {
                _interruptProgrammaticScroll();
              } else if (notification is ScrollUpdateNotification &&
                  notification.dragDetails != null) {
                _interruptProgrammaticScroll();
              }
              return false;
            },
            child: _ScrollRevealScope(
              controller: scrollController,
              metricsRevision: revealMetricsRevision,
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: (_) {
                  revealMetricsRevision.value++;
                  return false;
                },
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _NavbarDelegate(
                        minHeight: 72,
                        maxHeight: 72,
                        child: _Navbar(
                          key: navbarKey,
                          state: state,
                          locale: locale,
                          brandName: profile!.englishFirstName,
                          onNavigate: _scrollTo,
                          onPdf: () => _downloadPdf(state, locale),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _Section(
                            key: keys[AppSection.home],
                            child: _Hero(
                              profile!,
                              locale,
                              onProjects: () => _scrollTo(AppSection.projects),
                              onContact: () => _scrollTo(AppSection.contact),
                            ),
                          ),
                          _OceanWaveDivider(
                            isDark:
                                Theme.of(context).brightness == Brightness.dark,
                            isFooterEdge: false,
                          ),
                          _Section(
                            key: keys[AppSection.about],
                            child: _About(
                              profile!,
                              locale,
                              accentKey: headerKeys[AppSection.about]!,
                            ),
                          ),
                          _Section(
                            key: keys[AppSection.timeline],
                            child: _Timeline(
                              profile!,
                              locale,
                              accentKey: headerKeys[AppSection.timeline]!,
                            ),
                          ),
                          _Section(
                            key: keys[AppSection.projects],
                            child: _Projects(
                              projects,
                              links!,
                              state,
                              locale,
                              accentKey: headerKeys[AppSection.projects]!,
                            ),
                          ),
                          _BackToTopButton(
                            locale: locale,
                            onPressed: () => _scrollTo(AppSection.home),
                          ),
                          _OceanWaveDivider(
                            isDark:
                                Theme.of(context).brightness == Brightness.dark,
                            isFooterEdge: true,
                          ),
                          _Section(
                            key: keys[AppSection.contact],
                            child: _Footer(
                              profile: profile!,
                              links: links!,
                              locale: locale,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
