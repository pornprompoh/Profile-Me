/// หน้าที่หลัก: ประกอบหน้า Portfolio และเชื่อม State เข้ากับ UI
part of '../portfolio_ui.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
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
  late PortfolioScrollController _portfolioScrollController;
  bool _scrollControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scrollControllerInitialized) return;
    _portfolioScrollController = PortfolioScrollController(
      scrollController: scrollController,
      activeSection: AppStateScope.of(context).activeSection,
      sectionKeys: keys,
      headerKeys: headerKeys,
      navbarKey: navbarKey,
      viewportWidth: () => MediaQuery.sizeOf(context).width,
    );
    _scrollControllerInitialized = true;
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

  Future<void> _scrollTo(AppSection section, [bool fromDrawer = false]) async {
    await _portfolioScrollController.scrollTo(
      section,
      context,
      fromDrawer: fromDrawer,
    );
  }

  @override
  void dispose() {
    _portfolioScrollController.dispose();
    scrollController.dispose();
    revealMetricsRevision.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (profile == null || links == null) {
      return Scaffold(
        body: Center(
          child: Text(AppStrings.contentLoadError(state.locale.value)),
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
              _portfolioScrollController.interruptProgrammaticScroll();
            }
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is UserScrollNotification &&
                  notification.direction != ScrollDirection.idle) {
                _portfolioScrollController.interruptProgrammaticScroll();
              } else if (notification is ScrollUpdateNotification &&
                  notification.dragDetails != null) {
                _portfolioScrollController.interruptProgrammaticScroll();
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
