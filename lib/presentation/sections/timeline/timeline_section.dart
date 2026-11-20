// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../../../main.dart';

class _Timeline extends StatelessWidget {
  const _Timeline(this.profile, this.locale);
  final Profile profile;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: locale == AppLocale.th
                ? 'ประวัติและประสบการณ์'
                : 'Education & Experience',
            subtitle: locale == AppLocale.th
                ? 'เส้นทางการเรียนรู้และการทำงาน'
                : 'Learning and career journey',
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
    required this.delay,
  });
  final String period;
  final String title;
  final String organization;
  final String details;
  final bool education;
  final Duration delay;

  @override
  Widget build(BuildContext context) => _ScrollReveal(
    delay: delay,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  education ? Icons.school : Icons.work,
                  size: 17,
                  color: Colors.white,
                ),
              ),
              Container(width: 3, height: 120, color: AppTheme.sky),
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (organization.isNotEmpty)
                      Text(
                        organization,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.primary),
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
  );
}

