import 'package:flutter_test/flutter_test.dart';
import 'package:profile_me/core/theme/layout_tokens.dart';

void main() {
  test(
    'project grid uses available content width for columns and page size',
    () {
      expect(LayoutTokens.projectColumnCount(1004), 3);
      expect(LayoutTokens.projectVisibleLimit(1004), 6);

      expect(LayoutTokens.projectColumnCount(704), 2);
      expect(LayoutTokens.projectVisibleLimit(704), 4);

      expect(LayoutTokens.projectColumnCount(350), 1);
      expect(LayoutTokens.projectVisibleLimit(350), 3);
    },
  );
}
