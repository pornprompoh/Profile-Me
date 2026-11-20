import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/layout_tokens.dart';
import '../../core/state/app_state.dart';
import '../../data/models/content_models.dart';

class ProjectLinkButton extends StatelessWidget {
  const ProjectLinkButton({
    required this.link,
    required this.locale,
    this.compact = false,
    super.key,
  });

  final ProjectLink link;
  final AppLocale locale;
  final bool compact;

  Future<void> _openLink() => launchUrl(
    Uri.parse(link.url),
    mode: LaunchMode.externalApplication,
  );

  @override
  Widget build(BuildContext context) {
    final isGithub = link.type.toLowerCase() == 'github';
    final label = locale == AppLocale.th ? link.label.th : link.label.en;
    return OutlinedButton.icon(
      onPressed: _openLink,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(compact ? 44 : 118, LayoutTokens.touchTarget),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 18,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LayoutTokens.controlRadius),
        ),
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF7DD3FC)
            : Theme.of(context).colorScheme.primary,
      ),
      icon: Icon(isGithub ? Icons.code_rounded : Icons.open_in_new_rounded),
      label: Text(label.isEmpty ? (isGithub ? 'GitHub' : 'Open') : label),
    );
  }
}
