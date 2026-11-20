// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../../../main.dart';

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

