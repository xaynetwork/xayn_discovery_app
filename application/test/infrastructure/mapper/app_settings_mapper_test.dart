import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_theme_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/discovery_feed_axis_mapper.dart';

import 'app_settings_mapper_test.mocks.dart';

@GenerateMocks([
  IntToAppThemeMapper,
  AppThemeToIntMapper,
  IntToDiscoveryFeedAxisMapper,
  DiscoveryFeedAxisToIntMapper,
])
void main() {
  late AppSettingsMapper mapper;

  late MockIntToAppThemeMapper mockIntToAppThemeMapper;
  late MockAppThemeToIntMapper mockAppThemeToIntMapper;
  late MockIntToDiscoveryFeedAxisMapper mockIntToDiscoveryFeedAxisMapper;
  late MockDiscoveryFeedAxisToIntMapper mockDiscoveryFeedAxisToIntMapper;

  setUp(() async {
    mockIntToAppThemeMapper = MockIntToAppThemeMapper();
    mockAppThemeToIntMapper = MockAppThemeToIntMapper();
    mockIntToDiscoveryFeedAxisMapper = MockIntToDiscoveryFeedAxisMapper();
    mockDiscoveryFeedAxisToIntMapper = MockDiscoveryFeedAxisToIntMapper();

    mapper = AppSettingsMapper(
      mockIntToAppThemeMapper,
      mockAppThemeToIntMapper,
      mockIntToDiscoveryFeedAxisMapper,
      mockDiscoveryFeedAxisToIntMapper,
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

      final map = {
        0: true,
        1: 2,
        2: 1,
      };
      final settings = mapper.fromMap(map);
      expect(
        settings,
        AppSettings.global(
          isOnboardingDone: true,
          appTheme: AppTheme.dark,
          discoveryFeedAxis: DiscoveryFeedAxis.horizontal,
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

      final settings = AppSettings.global(
        isOnboardingDone: true,
        appTheme: AppTheme.dark,
        discoveryFeedAxis: DiscoveryFeedAxis.horizontal,
      );
      final map = mapper.toMap(settings);
      final expectedMap = {
        0: true,
        1: 2,
        2: 1,
      };
      expect(map, expectedMap);
    });
  });
}
