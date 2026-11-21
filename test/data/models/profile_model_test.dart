import 'package:flutter_test/flutter_test.dart';
import 'package:profile_me/data/models/profile_model.dart';

void main() {
  test('missing Hero fields fall back to empty tagline and skill groups', () {
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
    expect(profile.heroTechStack, [
      'Dart',
      'JavaScript',
      'HTML',
      'Flutter',
      'Firebase',
      'Supabase',
    ]);
  });

  test('configured Hero Tech Stack is trimmed to six entries', () {
    final profile = Profile.fromJson({
      'heroTagline': {'th': 'คำโปรยไทย', 'en': 'English tagline'},
      'heroTechStack': [
        'Dart',
        'Flutter',
        'Firebase',
        'HTML',
        'CSS',
        'JS',
        'SQL',
      ],
    });

    expect(profile.heroTagline.en, 'English tagline');
    expect(profile.heroTechStack, [
      'Dart',
      'Flutter',
      'Firebase',
      'HTML',
      'CSS',
      'JS',
    ]);
  });
}
