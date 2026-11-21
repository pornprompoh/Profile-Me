/// หน้าที่หลัก: ควบคุม Scroll Spy และการเลื่อนหน้าแบบ Smooth/Reduced Motion
library;

import 'package:flutter/material.dart';

import '../../core/state/app_state.dart';
import '../../core/theme/layout_tokens.dart';

class PortfolioScrollController {
  PortfolioScrollController({
    required this.scrollController,
    required this.activeSection,
    required this.sectionKeys,
    required this.headerKeys,
    required this.navbarKey,
    required this.viewportWidth,
  }) {
    scrollController.addListener(_updateActiveSection);
  }

  static const double scrollNoOpTolerance = 10;
  static const Duration scrollDuration = Duration(milliseconds: 550);

  final ScrollController scrollController;
  final ValueNotifier<AppSection> activeSection;
  final Map<AppSection, GlobalKey> sectionKeys;
  final Map<AppSection, GlobalKey> headerKeys;
  final GlobalKey navbarKey;
  final double Function() viewportWidth;

  bool _isProgrammaticScrolling = false;
  int _scrollAnimationToken = 0;

  double _actualNavbarHeight() {
    final box = navbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) return box.size.height;
    return LayoutTokens.navbarHeight;
  }

  double _breathingGap() =>
      viewportWidth() < LayoutTokens.mobileBreakpoint ? 20 : 24;

  double _scrollSpyLine() => _actualNavbarHeight() + _breathingGap();

  void interruptProgrammaticScroll() {
    if (!_isProgrammaticScrolling) return;
    _scrollAnimationToken++;
    _isProgrammaticScrolling = false;
    _updateActiveSection();
  }

  void _updateActiveSection() {
    if (_isProgrammaticScrolling) return;
    var closest = AppSection.home;
    var distance = double.infinity;
    final spyLine = _scrollSpyLine();

    void inspectKeys(Map<AppSection, GlobalKey> keys) {
      for (final entry in keys.entries) {
        final box =
            entry.value.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) continue;
        final value = (box.localToGlobal(Offset.zero).dy - spyLine).abs();
        if (value < distance) {
          distance = value;
          closest = entry.key;
        }
      }
    }

    inspectKeys(sectionKeys);
    inspectKeys(headerKeys);
    if (activeSection.value != closest) activeSection.value = closest;
  }

  double? _targetOffset(AppSection section) {
    if (!scrollController.hasClients) return null;
    if (section == AppSection.home) return 0;
    if (section == AppSection.contact) {
      return scrollController.position.maxScrollExtent;
    }

    final headerBox =
        headerKeys[section]?.currentContext?.findRenderObject() as RenderBox?;
    final box = headerBox != null && headerBox.hasSize
        ? headerBox
        : sectionKeys[section]?.currentContext?.findRenderObject()
              as RenderBox?;
    if (box == null || !box.hasSize) return null;

    final target =
        box.localToGlobal(Offset.zero).dy +
        scrollController.offset -
        _actualNavbarHeight() -
        _breathingGap();
    return target.clamp(0, scrollController.position.maxScrollExtent);
  }

  Future<void> scrollTo(
    AppSection section,
    BuildContext context, {
    bool fromDrawer = false,
  }) async {
    activeSection.value = section;
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) return;

    if (fromDrawer && !MediaQuery.disableAnimationsOf(context)) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      if (!context.mounted || !scrollController.hasClients) return;
    }

    final targetOffset = _targetOffset(section);
    if (targetOffset == null) return;
    if ((scrollController.offset - targetOffset).abs() <= scrollNoOpTolerance) {
      activeSection.value = section;
      return;
    }

    if (MediaQuery.disableAnimationsOf(context)) {
      _scrollAnimationToken++;
      _isProgrammaticScrolling = false;
      scrollController.jumpTo(targetOffset);
      activeSection.value = section;
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
        activeSection.value = section;
      }
    }
  }

  void dispose() {
    scrollController.removeListener(_updateActiveSection);
  }
}
