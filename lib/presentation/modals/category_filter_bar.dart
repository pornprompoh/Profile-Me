/// หน้าที่หลัก: แสดงตัวกรองหมวดหมู่แนวนอนและเลื่อนชิปที่เลือกให้อยู่ในมุมมอง
library;

import 'package:flutter/material.dart';

class CategoryFilterBar extends StatefulWidget {
  const CategoryFilterBar({
    required this.categories,
    required this.selected,
    required this.allLabel,
    required this.onSelected,
    super.key,
  });

  final List<String> categories;
  final String selected;
  final String allLabel;
  final ValueChanged<String> onSelected;

  @override
  State<CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<CategoryFilterBar> {
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
  void didUpdateWidget(covariant CategoryFilterBar oldWidget) {
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
