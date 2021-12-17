import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_theme_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/discovery_feed_axis_mapper.dart';

import 'app_settings_mapper_test.mocks.dart';

@GenerateMocks([
  IntToAppThemeMapper,
  AppThemeToIntMapper,
  IntToDiscoveryFeedAxisMapper,
  DiscoveryFeedAxisToIntMapper,
  MapToAppVersionMapper,
  AppVersionToMapMapper,
])
void main() {
  late AppSettingsMapper mapper;

  late MockIntToAppThemeMapper mockIntToAppThemeMapper;
  late MockAppThemeToIntMapper mockAppThemeToIntMapper;
  late MockIntToDiscoveryFeedAxisMapper mockIntToDiscoveryFeedAxisMapper;
  late MockDiscoveryFeedAxisToIntMapper mockDiscoveryFeedAxisToIntMapper;
  late MockMapToAppVersionMapper mockMapToAppVersionMapper;
  late MockAppVersionToMapMapper mockAppVersionToMapMapper;

  setUp(() async {
    mockIntToAppThemeMapper = MockIntToAppThemeMapper();
    mockAppThemeToIntMapper = MockAppThemeToIntMapper();
    mockIntToDiscoveryFeedAxisMapper = MockIntToDiscoveryFeedAxisMapper();
    mockDiscoveryFeedAxisToIntMapper = MockDiscoveryFeedAxisToIntMapper();
    mockMapToAppVersionMapper = MockMapToAppVersionMapper();
    mockAppVersionToMapMapper = MockAppVersionToMapMapper();

    mapper = AppSettingsMapper(
      mockIntToAppThemeMapper,
      mockAppThemeToIntMapper,
      mockIntToDiscoveryFeedAxisMapper,
      mockDiscoveryFeedAxisToIntMapper,
      mockMapToAppVersionMapper,
      mockAppVersionToMapMapper,
    );
  });

  group('AppSettingsMapper tests: ', () {
    test('fromMap', () {
      when(mockIntToAppThemeMapper.map(2)).thenAnswer(
        (_) => AppTheme.dark,
      );
      when(mockIntToDiscoveryFeedAxisMapper.map(1)).thenAnswer(
        (_) => DiscoveryFeedAxis.horizontal,
      );
      when(mockMapToAppVersionMapper.map({0: '1.0.0', 1: '123'})).thenAnswer(
        (_) => const AppVersion(version: '1.0.0', build: '123'),
      );

      final map = {
        0: true,
        1: 2,
        2: 1,
        3: 10,
        4: {0: '1.0.0', 1: '123'},
      };
      final settings = mapper.fromMap(map);
      expect(
        settings,
        AppSettings.global(
          isOnboardingDone: true,
          appTheme: AppTheme.dark,
          discoveryFeedAxis: DiscoveryFeedAxis.horizontal,
          numberOfSessions: 10,
          appVersion: const AppVersion(version: '1.0.0', build: '123'),
        ),
      );
    });

    test('toMap', () {
      when(mockAppThemeToIntMapper.map(AppTheme.dark)).thenAnswer(
        (_) => 2,
      );
      when(mockDiscoveryFeedAxisToIntMapper.map(DiscoveryFeedAxis.horizontal))
          .thenAnswer(
        (_) => 1,
      );
      when(mockAppVersionToMapMapper
              .map(const AppVersion(version: '1.0.0', build: '123')))
          .thenAnswer(
        (_) => {0: '1.0.0', 1: '123'},
      );

      final settings = AppSettings.global(
        isOnboardingDone: true,
        appTheme: AppTheme.dark,
        discoveryFeedAxis: DiscoveryFeedAxis.horizontal,
        numberOfSessions: 10,
        appVersion: const AppVersion(version: '1.0.0', build: '123'),
      );
      final map = mapper.toMap(settings);
      final expectedMap = {
        0: true,
        1: 2,
        2: 1,
        3: 10,
        4: {0: '1.0.0', 1: '123'},
      };
      expect(map, expectedMap);
    });
  });
}
