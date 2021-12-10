import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_theme_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/discovery_feed_axis_mapper.dart';

void main() {
  late AppSettingsMapper mapper;

  setUp(() async {
    mapper = const AppSettingsMapper(
      IntToAppThemeMapper(),
      AppThemeToIntMapper(),
      IntToDiscoveryFeedAxisMapper(),
      DiscoveryFeedAxisToIntMapper(),
    );
  });

  group('AppSettingsMapper tests: ', () {
    test('fromMap', () {
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
