// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../../main.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final repository = ContentRepository();
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
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
    if (scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeEndDrawer();
    }
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
        key: scaffoldKey,
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
                      socialLinks: links!.socialLinks,
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
                    ],
                  ),
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
