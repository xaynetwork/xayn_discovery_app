import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_theme_mapper.dart';

import 'app_settings_mapper_test.mocks.dart';

@GenerateMocks([
  IntToAppThemeMapper,
  AppThemeToIntMapper,
])
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
        0: true,
        1: 2,
        2: 'installation_id',
      };
      final settings = mapper.fromMap(map);
      expect(
        settings,
        AppSettings.global(
          isOnboardingDone: true,
          appTheme: AppTheme.dark,
          installationId: const UniqueId.fromTrustedString('installation_id'),
        ),
      );
    });

    test('toMap', () {
      when(mockAppThemeToIntMapper.map(AppTheme.dark)).thenAnswer(
        (_) => 2,
      );

      final settings = AppSettings.global(
        isOnboardingDone: true,
        appTheme: AppTheme.dark,
        installationId: const UniqueId.fromTrustedString('installation_id'),
      );
      final map = mapper.toMap(settings);
      final expectedMap = {
        0: true,
        1: 2,
        2: 'installation_id',
      };
      expect(map, expectedMap);
    });
  });
}
