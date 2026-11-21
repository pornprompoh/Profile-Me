// หน้าที่หลัก: การ์ดสรุปผลงานและการเปิดรายละเอียดโครงการ
part of '../../../main.dart';

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
    final isMobile =
        MediaQuery.sizeOf(context).width < LayoutTokens.mobileBreakpoint;
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
    final visibleTags = project.tags.take(isMobile ? 2 : 4).toList();
    final remainingTags = project.tags.length - visibleTags.length;

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
                aspectRatio: isMobile ? 2 : 16 / 9,
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
                  padding: EdgeInsets.all(
                    isMobile ? 12 : LayoutTokens.cardPadding,
                  ),
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
                      SizedBox(height: isMobile ? 4 : 6),
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
                      SizedBox(height: isMobile ? 4 : 6),
                      Text(
                        locale == AppLocale.th
                            ? project.summary.th
                            : project.summary.en,
                        maxLines: isMobile ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: isMobile ? 4 : 6,
                        children: [
                          for (final tag in visibleTags)
                            Chip(
                              label: Text(tag),
                              visualDensity: VisualDensity.compact,
                            ),
                          if (isMobile && remainingTags > 0)
                            Chip(
                              label: Text('+$remainingTags'),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      if (githubLink != null) ...[
                        SizedBox(height: isMobile ? 6 : 10),
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
