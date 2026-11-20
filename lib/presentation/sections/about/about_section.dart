// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../../../main.dart';

class _About extends StatelessWidget {
  const _About(this.profile, this.locale);
  final Profile profile;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < LayoutTokens.mobileBreakpoint;
    return SectionContainer(
      child: _ScrollReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: locale == AppLocale.th ? 'เกี่ยวกับฉัน' : 'About Me',
              subtitle: locale == AppLocale.th
                  ? 'ประวัติและจุดสนใจ'
                  : 'Background and interests',
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) => isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale == AppLocale.th
                              ? profile.bio.th
                              : profile.bio.en,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(height: 1.75),
                        ),
                        const SizedBox(height: 20),
                        _AboutFacts(profile: profile, locale: locale),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            locale == AppLocale.th
                                ? profile.bio.th
                                : profile.bio.en,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(height: 1.75),
                          ),
                        ),
                        const SizedBox(width: 36),
                        Expanded(
                          flex: 2,
                          child: _AboutFacts(profile: profile, locale: locale),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
            for (final group in profile.skillGroups)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale == AppLocale.th ? group.title.th : group.title.en,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final skill in group.skills)
                          Chip(
                            label: Text(skill),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AboutFacts extends StatelessWidget {
  const _AboutFacts({required this.profile, required this.locale});
  final Profile profile;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.primaryContainer.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? .28 : .55,
    );
    return Container(
      padding: const EdgeInsets.all(LayoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(LayoutTokens.cardRadius),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cake_outlined),
              const SizedBox(width: 10),
              Text(
                '${locale == AppLocale.th ? 'อายุ' : 'Age'} ${profile.age}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.mail_outline),
              const SizedBox(width: 10),
              Expanded(
                child: SelectableText(
                  profile.email,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.subtitle);
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) =>
      SectionHeader(title: title, subtitle: subtitle);
}

