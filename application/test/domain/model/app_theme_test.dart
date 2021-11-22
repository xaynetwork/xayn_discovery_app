import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';

void main() {
  test(
    'GIVEN AppTheme values THEN verify size equal 3',
    () {
      expect(AppTheme.values.length, equals(3));
    },
  );
  test(
    'GIVEN AppTheme values THEN verify correct names',
    () {
      final expectedNames = [
        'system',
        'light',
        'dark',
      ];
      final realNames = AppTheme.values
          .map((e) => e.toString().substring(e.toString().indexOf('.') + 1))
          .toList(growable: false);
      expect(realNames, equals(expectedNames));
    },
  );
}
