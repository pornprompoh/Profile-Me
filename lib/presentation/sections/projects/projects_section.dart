// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../../../main.dart';

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
            accentKey: widget.accentKey,
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
