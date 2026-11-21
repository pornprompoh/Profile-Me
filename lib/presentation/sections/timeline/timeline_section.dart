// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../../../main.dart';

class _Timeline extends StatelessWidget {
  const _Timeline(this.profile, this.locale, {required this.accentKey});
  final Profile profile;
  final AppLocale locale;
  final Key accentKey;

  @override
  Widget build(BuildContext context) {
    final hasExperience = profile.experience.isNotEmpty;
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            accentKey: accentKey,
            title: locale == AppLocale.th
                ? (hasExperience ? 'ประวัติและประสบการณ์' : 'ประวัติการศึกษา')
                : (hasExperience ? 'Education & Experience' : 'Education'),
            subtitle: locale == AppLocale.th
                ? (hasExperience
                      ? 'เส้นทางการเรียนรู้และการทำงาน'
                      : 'เส้นทางการเรียนรู้')
                : (hasExperience
                      ? 'Learning and career journey'
                      : 'Academic background'),
          ),
          const SizedBox(height: 32),
          for (var i = 0; i < profile.education.length; i++)
            _TimelineItem(
              period: profile.education[i].period,
              title: locale == AppLocale.th
                  ? profile.education[i].field.th
                  : profile.education[i].field.en,
              organization: locale == AppLocale.th
                  ? profile.education[i].institution.th
                  : profile.education[i].institution.en,
              details: locale == AppLocale.th
                  ? profile.education[i].details.th
                  : profile.education[i].details.en,
              education: true,
              isLast:
                  i == profile.education.length - 1 &&
                  profile.experience.isEmpty,
              delay: Duration(milliseconds: i * 80),
            ),
          for (var i = 0; i < profile.experience.length; i++)
            _TimelineItem(
              period: profile.experience[i].period,
              title: locale == AppLocale.th
                  ? profile.experience[i].role.th
                  : profile.experience[i].role.en,
              organization: locale == AppLocale.th
                  ? profile.experience[i].organization.th
                  : profile.experience[i].organization.en,
              details: locale == AppLocale.th
                  ? profile.experience[i].details.th
                  : profile.experience[i].details.en,
              education: false,
              isLast: i == profile.experience.length - 1,
              delay: Duration(
                milliseconds: (i + profile.education.length) * 80,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.period,
    required this.title,
    required this.organization,
    required this.details,
    required this.education,
    required this.isLast,
    required this.delay,
  });
  final String period;
  final String title;
  final String organization;
  final String details;
  final bool education;
  final bool isLast;
  final Duration delay;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
    child: _ScrollReveal(
      delay: delay,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      education ? Icons.school : Icons.work,
                      size: 17,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 3,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .28),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _HoverWrapper(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (period.isNotEmpty)
                          Chip(
                            label: Text(period),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                        if (title.isNotEmpty)
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        if (organization.isNotEmpty)
                          Text(
                            organization,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        if (details.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(details),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
