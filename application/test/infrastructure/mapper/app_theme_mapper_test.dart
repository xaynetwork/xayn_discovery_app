import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_theme_mapper.dart';

void main() {
  late IntToAppThemeMapper intToAppThemeMapper;
  late AppThemeToIntMapper appThemeToIntMapper;

  setUp(() async {
    intToAppThemeMapper = const IntToAppThemeMapper();
    appThemeToIntMapper = const AppThemeToIntMapper();
  });
  test('IntToAppThemeMapper tests', () {
    final data = <int?, AppTheme>{
      0: AppTheme.system,
      1: AppTheme.light,
      2: AppTheme.dark,
      666: AppTheme.system,
      null: AppTheme.system,
    };
    final results = <AppTheme>[];
    for (final value in data.keys) {
      results.add(intToAppThemeMapper.map(value));
    }
    expect(results, equals(data.values));
  });

  test('AppThemeToIntMapper tests', () {
    final results = <int>[];
    for (final theme in AppTheme.values) {
      results.add(appThemeToIntMapper.map(theme));
    }
    expect(results, [0, 1, 2]);
  });
}
