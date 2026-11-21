import 'package:flutter_test/flutter_test.dart';
import 'package:profile_me/data/models/profile_model.dart';

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
}
