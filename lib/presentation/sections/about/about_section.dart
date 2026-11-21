// หน้าที่หลัก: ประกอบบล็อกประวัติ รูป กิจกรรม และทักษะของส่วน About
part of '../../../main.dart';

class _About extends StatelessWidget {
  const _About(this.profile, this.locale);

  final Profile profile;
  final AppLocale locale;

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
                  const SizedBox(height: 20),
                  _AboutActivitiesGrid(
                    activities: profile.activities,
                    locale: locale,
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 36, child: _AboutPhotoCard(profile: profile)),
                  const SizedBox(width: 36),
                  Expanded(
                    flex: 64,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AboutBio(bio: bio),
                        const SizedBox(height: 20),
                        _AboutActivitiesGrid(
                          activities: profile.activities,
                          locale: locale,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            _AboutSkillsGrid(groups: profile.skillGroups, locale: locale),
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
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      height: 1.78,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}
