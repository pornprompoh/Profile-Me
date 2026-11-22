/// หน้าที่หลัก: แสดงตัวกรอง หมวดหมู่ และ Grid ผลงาน
part of '../../portfolio_ui.dart';

class _Projects extends StatefulWidget {
  const _Projects(
    this.projects,
    this.links,
    this.state,
    this.locale, {
    required this.accentKey,
  });
  final List<Project> projects;
  final Links links;
  final AppState state;
  final AppLocale locale;
  final Key accentKey;

  @override
  State<_Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<_Projects> {
  final ScrollController _filterController = ScrollController();
  var _canScrollFilterLeft = false;
  var _canScrollFilterRight = false;

  @override
  void initState() {
    super.initState();
    _filterController.addListener(_updateFilterScroll);
  }

  @override
  void didUpdateWidget(covariant _Projects oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateFilterScroll();
    });
  }

  @override
  void dispose() {
    _filterController.removeListener(_updateFilterScroll);
    _filterController.dispose();
    super.dispose();
  }

  void _updateFilterScroll() {
    if (!mounted) return;
    final position = _filterController.positions.isEmpty
        ? null
        : _filterController.position;
    if (position == null) return;
    final left = position.pixels > 1;
    final right = position.pixels < position.maxScrollExtent - 1;
    if (left != _canScrollFilterLeft || right != _canScrollFilterRight) {
      setState(() {
        _canScrollFilterLeft = left;
        _canScrollFilterRight = right;
      });
    }
  }

  void _scrollFilters(double offset) {
    if (!_filterController.hasClients) return;
    final target = (_filterController.offset + offset).clamp(
      0.0,
      _filterController.position.maxScrollExtent,
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      _filterController.jumpTo(target);
    } else {
      _filterController.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

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

  int _categoryCount(String category) => widget.projects
      .where(
        (project) =>
            (widget.locale == AppLocale.th
                ? project.category.th
                : project.category.en) ==
            category,
      )
      .length;

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
            accentKey: widget.accentKey,
            title: widget.locale == AppLocale.th ? 'ผลงาน' : 'Projects',
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<String>(
            valueListenable: widget.state.selectedCategory,
            builder: (context, selected, _) {
              final currentSelection = _categoryInCurrentLocale(selected);
              final allLabel = widget.locale == AppLocale.th
                  ? 'ทั้งหมด'
                  : 'All';
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < LayoutTokens.mobileBreakpoint) {
                    return _MobileCategoryDropdown(
                      projects: widget.projects,
                      categories: categories,
                      selected: currentSelection,
                      locale: widget.locale,
                      onSelected: (value) =>
                          widget.state.selectedCategory.value = value,
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _updateFilterScroll();
                  });
                  return Row(
                    children: [
                      if (_canScrollFilterLeft)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: IconButton(
                            tooltip: null,
                            onPressed: () => _scrollFilters(-220),
                            icon: const Icon(Icons.chevron_left),
                            constraints: const BoxConstraints.tightFor(
                              width: 36,
                              height: 36,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ShaderMask(
                          blendMode: BlendMode.dstIn,
                          shaderCallback: (bounds) => LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              _canScrollFilterLeft
                                  ? Colors.transparent
                                  : Colors.white,
                              Colors.white,
                              Colors.white,
                              _canScrollFilterRight
                                  ? Colors.transparent
                                  : Colors.white,
                            ],
                            stops: const [0, .04, .96, 1],
                          ).createShader(bounds),
                          child: NotificationListener<ScrollMetricsNotification>(
                            onNotification: (_) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) _updateFilterScroll();
                              });
                              return false;
                            },
                            child: SingleChildScrollView(
                              controller: _filterController,
                              scrollDirection: Axis.horizontal,
                              physics: const ClampingScrollPhysics(),
                              child: Row(
                                children: [
                                  ChoiceChip(
                                    label: Text(
                                      '$allLabel (${widget.projects.length})',
                                    ),
                                    selected: currentSelection == 'all',
                                    onSelected: (_) =>
                                        widget.state.selectedCategory.value =
                                            'all',
                                  ),
                                  const SizedBox(width: 8),
                                  for (final category in categories) ...[
                                    ChoiceChip(
                                      label: Text(
                                        '$category (${_categoryCount(category)})',
                                      ),
                                      selected: currentSelection == category,
                                      onSelected: (_) =>
                                          widget.state.selectedCategory.value =
                                              category,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_canScrollFilterRight)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: IconButton(
                            tooltip: null,
                            onPressed: () => _scrollFilters(220),
                            icon: const Icon(Icons.chevron_right),
                            constraints: const BoxConstraints.tightFor(
                              width: 36,
                              height: 36,
                            ),
                          ),
                        ),
                    ],
                  );
                },
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
                      final cardWidth =
                          (width -
                              LayoutTokens.projectGridSpacing * (columns - 1)) /
                          columns;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: LayoutTokens.projectGridSpacing,
                          crossAxisSpacing: LayoutTokens.projectGridSpacing,
                          mainAxisExtent: LayoutTokens.projectCardExtent(
                            cardWidth,
                            compact: width < LayoutTokens.mobileBreakpoint,
                          ),
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final visibleLimit = LayoutTokens.projectVisibleLimit(
                        constraints.maxWidth,
                      );
                      if (filtered.length <= visibleLimit) {
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
