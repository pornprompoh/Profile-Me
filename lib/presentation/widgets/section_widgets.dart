import 'package:flutter/material.dart';

import '../../core/theme/layout_tokens.dart';

class SectionContainer extends StatelessWidget {
  const SectionContainer({
    required this.child,
    this.verticalPadding,
    this.background,
    super.key,
  });

  final Widget child;
  final double? verticalPadding;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    final padding = verticalPadding ?? LayoutTokens.sectionPadding(context);
    return Stack(
      children: [
        if (background != null) Positioned.fill(child: background!),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            LayoutTokens.horizontalPadding(context),
            padding,
            LayoutTokens.horizontalPadding(context),
            padding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: LayoutTokens.maxContentWidth,
              ),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle = '',
    this.accentKey,
    super.key,
  });

  final String title;
  final String subtitle;
  final Key? accentKey;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      KeyedSubtree(
        key: accentKey,
        child: Container(
          width: 52,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: LayoutTokens.sectionTitleSize(context),
          fontWeight: FontWeight.w800,
          height: 1.18,
        ),
      ),
      if (subtitle.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            height: 1.55,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ],
  );
}
