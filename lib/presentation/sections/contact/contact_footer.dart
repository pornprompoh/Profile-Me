// หน้าที่หลัก: UI และตรรกะสำหรับส่วนนี้ของ Portfolio
part of '../../../main.dart';

class _Contact extends StatelessWidget {
  const _Contact(this.profile, this.links, this.state, this.locale);
  final Profile profile;
  final Links links;
  final AppState state;
  final AppLocale locale;

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: profile.email));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          locale == AppLocale.th
              ? 'คัดลอกอีเมลแล้ว'
              : 'Email copied to clipboard',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: _ScrollReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              locale == AppLocale.th ? 'ติดต่อ' : 'Contact',
              locale == AppLocale.th
                  ? 'ช่องทางสำหรับพูดคุยและทำงานร่วมกัน'
                  : 'Let us connect and build together',
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (profile.email.isNotEmpty)
                  FilledButton.icon(
                    onPressed: () => _copyEmail(context),
                    icon: const Icon(Icons.copy),
                    label: Text(profile.email),
                  ),
                for (final link in links.socialLinks)
                  OutlinedButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(link.url),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: Icon(
                      link.icon.toLowerCase().contains('github')
                          ? Icons.code
                          : link.icon.toLowerCase().contains('linkedin')
                          ? Icons.work
                          : Icons.link,
                    ),
                    label: Text(link.label),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.profile, required this.locale});
  final Profile profile;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final name = locale == AppLocale.th ? profile.names.th : profile.names.en;
    return SectionContainer(
      verticalPadding: 18,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        padding: const EdgeInsets.only(top: 18),
        child: Text(
          '© ${DateTime.now().year} $name. ${locale == AppLocale.th ? 'สงวนลิขสิทธิ์' : 'All rights reserved.'}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
