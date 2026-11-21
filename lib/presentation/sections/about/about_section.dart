/// หน้าที่หลัก: ประกอบรูป ประวัติ และทักษะของ About section
part of '../../portfolio_ui.dart';

class _About extends StatelessWidget {
  const _About(this.profile, this.locale, {required this.accentKey});

  final Profile profile;
  final AppLocale locale;
  final Key accentKey;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < LayoutTokens.mobileBreakpoint;
    final bio = profile.resolvedBio(locale);

    return SectionContainer(
      child: _ScrollReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              accentKey: accentKey,
              title: locale == AppLocale.th ? 'เกี่ยวกับฉัน' : 'About Me',
              subtitle: locale == AppLocale.th
                  ? 'ประวัติและจุดสนใจ'
                  : 'Background and interests',
            ),
            const SizedBox(height: 24),
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _AboutPhotoCard(profile: profile)),
                  const SizedBox(height: 24),
                  _AboutBio(bio: bio),
                  const SizedBox(height: 16),
                  _AboutSkillsGrid(groups: profile.skillGroups, locale: locale),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 36, child: _AboutPhotoCard(profile: profile)),
                  const SizedBox(width: 36),
                  Expanded(
                    flex: 64,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AboutBio(bio: bio),
                        const SizedBox(height: 16),
                        _AboutSkillsGrid(
                          groups: profile.skillGroups,
                          locale: locale,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AboutBio extends StatelessWidget {
  const _AboutBio({required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) => Text(
    bio,
    textAlign: TextAlign.justify,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      height: 1.78,
      wordSpacing: 0.1,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}
