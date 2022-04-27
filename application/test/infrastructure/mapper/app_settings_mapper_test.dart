import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_settings_mapper.dart';

import '../../test_utils/utils.dart';

void main() {
  late AppSettingsMapper mapper;

  late MockIntToAppThemeMapper mockIntToAppThemeMapper;
  late MockAppThemeToIntMapper mockAppThemeToIntMapper;

  setUp(() async {
    mockIntToAppThemeMapper = MockIntToAppThemeMapper();
    mockAppThemeToIntMapper = MockAppThemeToIntMapper();

    mapper = AppSettingsMapper(
      mockIntToAppThemeMapper,
      mockAppThemeToIntMapper,
    );
  });

  group('AppSettingsMapper tests: ', () {
    test('fromMap', () {
      when(mockIntToAppThemeMapper.map(2)).thenAnswer(
        (_) => AppTheme.dark,
      );

      final map = {
        AppSettingsFields.appTheme: 2,
      };
      final settings = mapper.fromMap(map);
      expect(
        settings,
        AppSettings.global(
          appTheme: AppTheme.dark,
        ),
      );
    });

    test('toMap', () {
      when(mockAppThemeToIntMapper.map(AppTheme.dark)).thenAnswer(
        (_) => 2,
      );

      final settings = AppSettings.global(
        appTheme: AppTheme.dark,
      );
      final map = mapper.toMap(settings);
      final expectedMap = {
        AppSettingsFields.appTheme: 2,
      };
      expect(map, expectedMap);
    });
  });
}
