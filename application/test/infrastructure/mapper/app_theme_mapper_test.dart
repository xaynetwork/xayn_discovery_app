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

  group('IntToAppThemeMapper tests: ', () {
    test('0 maps to AppTheme.system', () {
      final value = intToAppThemeMapper.map(0);
      expect(value, AppTheme.system);
    });

    test('1 maps to AppTheme.light', () {
      final value = intToAppThemeMapper.map(1);
      expect(value, AppTheme.light);
    });

    test('2 maps to AppTheme.dark', () {
      final value = intToAppThemeMapper.map(2);
      expect(value, AppTheme.dark);
    });

    test('null maps to AppTheme.system', () {
      final value = intToAppThemeMapper.map(null);
      expect(value, AppTheme.system);
    });

    test('666 maps to AppTheme.system', () {
      final value = intToAppThemeMapper.map(666);
      expect(value, AppTheme.system);
    });
  });

  group('AppThemeToIntMapper tests: ', () {
    test('AppTheme.system maps to 0', () {
      final value = appThemeToIntMapper.map(AppTheme.system);
      expect(value, 0);
    });

    test('AppTheme.light maps to 1', () {
      final value = appThemeToIntMapper.map(AppTheme.light);
      expect(value, 1);
    });

    test('AppTheme.dark maps to 2', () {
      final value = appThemeToIntMapper.map(AppTheme.dark);
      expect(value, 2);
    });
  });
}
