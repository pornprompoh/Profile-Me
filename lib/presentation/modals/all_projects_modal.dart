/// หน้าที่หลัก: แสดงรายการผลงานทั้งหมดและกรองตามหมวดหมู่
library;

import 'package:flutter/material.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/layout_tokens.dart';
import '../../data/models/content_models.dart';
import 'category_filter_bar.dart';

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
                  CategoryFilterBar(
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
