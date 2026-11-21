import 'package:flutter/material.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/layout_tokens.dart';
import '../../data/models/content_models.dart';

typedef ProjectCardBuilder = Widget Function(Project project);

class AllProjectsModal extends StatefulWidget {
  const AllProjectsModal({
    required this.projects,
    required this.initialCategory,
    required this.locale,
    required this.projectCardBuilder,
    super.key,
  });

  final List<Project> projects;
  final String initialCategory;
  final AppLocale locale;
  final ProjectCardBuilder projectCardBuilder;

  @override
  State<AllProjectsModal> createState() => _AllProjectsModalState();
}

class _AllProjectsModalState extends State<AllProjectsModal> {
  late final ValueNotifier<String> _selectedCategory;
  late final ScrollController _scrollController;

  bool get _isThai => widget.locale == AppLocale.th;

  @override
  void initState() {
    super.initState();
    // ตัวกรองนี้เป็นอิสระจากหมวดหมู่ที่เลือกบนหน้าหลัก
    _selectedCategory = ValueNotifier(widget.initialCategory);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _selectedCategory.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;
    final categories =
        widget.projects
            .map(
              (project) => _isThai ? project.category.th : project.category.en,
            )
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return ValueListenableBuilder<String>(
      valueListenable: _selectedCategory,
      builder: (context, selected, _) {
        final filtered = sortProjectsByFeaturedAndUpdated(
          widget.projects.where((project) {
            final category = _isThai
                ? project.category.th
                : project.category.en;
            return selected == 'all' || category == selected;
          }),
        );

        return Dialog(
          insetPadding: isMobile
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              isMobile ? 0 : LayoutTokens.modalRadius,
            ),
          ),
          child: SizedBox(
            width: isMobile
                ? size.width
                : (size.width - 64)
                      .clamp(0.0, LayoutTokens.maxContentWidth)
                      .toDouble(),
            height: isMobile
                ? size.height
                : (size.height - 48).clamp(0.0, 850.0).toDouble(),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: _isThai ? 'กลับ' : 'Back',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        if (size.width >= 460) Text(_isThai ? 'กลับ' : 'Back'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _isThai ? 'ผลงานทั้งหมด' : 'All Projects',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                _isThai
                                    ? '${filtered.length} ผลงาน'
                                    : '${filtered.length} projects',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: _isThai ? 'ปิด' : 'Close',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _CategoryFilterBar(
                    categories: categories,
                    selected: selected,
                    allLabel: _isThai ? 'ทั้งหมด' : 'All',
                    onSelected: (category) =>
                        _selectedCategory.value = category,
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final horizontalPadding = isMobile ? 12.0 : 24.0;
                        final gridWidth =
                            constraints.maxWidth - horizontalPadding * 2;
                        final columns = LayoutTokens.projectColumnCount(
                          gridWidth,
                        );
                        final cardWidth =
                            (gridWidth -
                                LayoutTokens.projectGridSpacing *
                                    (columns - 1)) /
                            columns;
                        return GridView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            16,
                            horizontalPadding,
                            28,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: LayoutTokens.projectCardExtent(
                                  cardWidth,
                                  compact:
                                      size.width <
                                      LayoutTokens.mobileBreakpoint,
                                ),
                                crossAxisSpacing:
                                    LayoutTokens.projectGridSpacing,
                                mainAxisSpacing:
                                    LayoutTokens.projectGridSpacing,
                              ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              widget.projectCardBuilder(filtered[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryFilterBar extends StatefulWidget {
  const _CategoryFilterBar({
    required this.categories,
    required this.selected,
    required this.allLabel,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final String allLabel;
  final ValueChanged<String> onSelected;

  @override
  State<_CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<_CategoryFilterBar> {
  late final ScrollController _controller;
  final Map<String, GlobalKey> _chipKeys = {};
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_updateScrollCue);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollCue();
      _ensureSelectedVisible();
    });
  }

  @override
  void didUpdateWidget(covariant _CategoryFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureSelectedVisible();
      });
    }
  }

  GlobalKey _keyFor(String category) =>
      _chipKeys.putIfAbsent(category, GlobalKey.new);

  void _updateScrollCue() {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    final canScrollLeft = position.pixels > 1;
    final canScrollRight = position.pixels < position.maxScrollExtent - 1;
    if (canScrollLeft == _canScrollLeft && canScrollRight == _canScrollRight) {
      return;
    }
    setState(() {
      _canScrollLeft = canScrollLeft;
      _canScrollRight = canScrollRight;
    });
  }

  void _ensureSelectedVisible() {
    final selectedContext = _chipKeys[widget.selected]?.currentContext;
    if (selectedContext == null) return;
    // จัดหมวดที่เลือกให้อยู่ในจอ ทั้งตอนเปิดหน้าต่างและเมื่อเปลี่ยนตัวกรอง
    Scrollable.ensureVisible(
      selectedContext,
      alignment: widget.selected == 'all' ? 0 : .5,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_updateScrollCue)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return SizedBox(
      height: 58,
      child: Stack(
        children: [
          NotificationListener<ScrollMetricsNotification>(
            onNotification: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateScrollCue();
              });
              return false;
            },
            child: SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  KeyedSubtree(
                    key: _keyFor('all'),
                    child: ChoiceChip(
                      label: Text(widget.allLabel),
                      selected: widget.selected == 'all',
                      onSelected: (_) => widget.onSelected('all'),
                    ),
                  ),
                  for (final category in widget.categories)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: KeyedSubtree(
                        key: _keyFor(category),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: widget.selected == category,
                          onSelected: (_) => widget.onSelected(category),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _canScrollLeft ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: SizedBox(
                  width: 24,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [surface, surface.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _canScrollRight ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: SizedBox(
                  width: 24,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [surface, surface.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
