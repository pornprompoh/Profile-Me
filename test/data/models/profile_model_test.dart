import 'package:flutter_test/flutter_test.dart';
import 'package:profile_me/data/models/profile_model.dart';
import 'package:profile_me/core/state/app_state.dart';

void main() {
  test('English name and watermark use only the first name', () {
    final profile = Profile.fromJson({
      'names': {'th': 'ชื่อไทย', 'en': '  Pornprom Sukjaimit  '},
    });

    expect(profile.englishFirstName, 'Pornprom');
    expect(profile.englishNameWatermark, 'PORNPROM');
  });

  test('missing tagline falls back without changing About skill groups', () {
    final profile = Profile.fromJson({
      'skillGroups': [
        {
          'title': {'th': 'Languages', 'en': 'Languages'},
          'skills': ['Dart', 'JavaScript', '', 'HTML'],
        },
        {
          'title': {'th': 'Tools', 'en': 'Tools'},
          'skills': ['Flutter', 'Firebase', 'Supabase'],
        },
      ],
    });

    expect(profile.heroTagline.th, isEmpty);
    expect(profile.heroTagline.en, isEmpty);
    expect(profile.skillGroups.first.skills, [
      'Dart',
      'JavaScript',
      '',
      'HTML',
    ]);
  });

  test('empty English name produces an empty watermark', () {
    final profile = Profile.fromJson({
      'names': {'th': 'ชื่อไทย', 'en': '   '},
    });

    expect(profile.englishNameWatermark, isEmpty);
  });

  test('resolved bio replaces age and supports About fallback fields', () {
    final profile = Profile.fromJson({
      'birthDate': '2000-01-01',
      'names': {'th': 'ทดสอบ ภาษาไทย', 'en': 'Test Person'},
      'profileImage': 'assets/profile-main.jpg',
      'bio': {'th': 'ฉันอายุ {age} ปี', 'en': 'I am {age} years old'},
      'phone': '065-567-2577',
    });

    expect(profile.resolvedBio(AppLocale.th), 'ฉันอายุ ${profile.age} ปี');
    expect(profile.resolvedBio(AppLocale.en), 'I am ${profile.age} years old');
    expect(profile.resolvedBio(AppLocale.en), isNot(contains('{age}')));
    expect(profile.aboutImage, 'assets/profile-main.jpg');
    expect(profile.phone, '065-567-2577');
    expect(profile.dialablePhone, '0655672577');
  });
}
