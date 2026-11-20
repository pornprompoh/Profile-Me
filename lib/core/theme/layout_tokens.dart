import 'package:flutter/material.dart';

class LayoutTokens {
  const LayoutTokens._();

  static const double mobileBreakpoint = 640;
  static const double tabletBreakpoint = 1024;
  static const double maxContentWidth = 1120;
  static const double navbarHeight = 72;

  static const double mobilePadding = 20;
  static const double tabletPadding = 32;
  static const double desktopPadding = 48;

  static const double mobileSectionPadding = 56;
  static const double desktopSectionPadding = 84;

  static const double cardPadding = 16;
  static const double modalPadding = 20;
  static const double drawerPadding = 16;
  static const double elementGap = 12;
  static const double touchTarget = 48;
  static const double projectGridSpacing = 18;
  static const double projectMinCardWidth = 280;

  static const double cardRadius = 20;
  static const double modalRadius = 24;
  static const double controlRadius = 14;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint) return desktopPadding;
    if (width >= mobileBreakpoint) return tabletPadding;
    return mobilePadding;
  }

  static double sectionPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint
        ? desktopSectionPadding
        : mobileSectionPadding;
  }

  static double heroNameSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > tabletBreakpoint) return 52;
    if (width < 840 && width >= mobileBreakpoint) return 38;
    if (width >= mobileBreakpoint) return 44;
    return 34;
  }

  static double heroRoleSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletBreakpoint
        ? 24
        : (width >= mobileBreakpoint ? 20 : 18);
  }

  static double sectionTitleSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletBreakpoint
        ? 36
        : (width >= mobileBreakpoint ? 30 : 26);
  }

  static double cardTitleSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < mobileBreakpoint ? 18 : 20;
  }

  static int projectVisibleLimit(double width) {
    return switch (projectColumnCount(width)) {
      1 => 3,
      2 => 4,
      _ => 6,
    };
  }

  static int projectColumnCount(double width) {
    final columns =
        ((width + projectGridSpacing) /
                (projectMinCardWidth + projectGridSpacing))
            .floor();
    return columns.clamp(1, 3).toInt();
  }

  static double projectCardExtent(double cardWidth) => cardWidth * 9 / 16 + 330;
}
