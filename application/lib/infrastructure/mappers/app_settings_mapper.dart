import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/discovery_feed_axis_mapper.dart';

import 'app_theme_mapper.dart';

@singleton
class AppSettingsMapper extends BaseDbEntityMapper<AppSettings> {
  final IntToAppThemeMapper _intToAppThemeMapper;
  final AppThemeToIntMapper _appThemeToIntMapper;
  final IntToDiscoveryFeedAxisMapper _intToDiscoveryFeedAxisMapper;
  final DiscoveryFeedAxisToIntMapper _discoveryFeedAxisToIntMapper;

  const AppSettingsMapper(
    this._intToAppThemeMapper,
    this._appThemeToIntMapper,
    this._intToDiscoveryFeedAxisMapper,
    this._discoveryFeedAxisToIntMapper,
  );

  @override
  AppSettings? fromMap(Map? map) {
    if (map == null) return null;

    final isOnboardingDone = map[AppSettingsFields.isOnboardingDone] as bool?;
    final appTheme = _intToAppThemeMapper.map(map[AppSettingsFields.appTheme]);
    final discoveryFeedAxis = _intToDiscoveryFeedAxisMapper
        .map(map[AppSettingsFields.discoveryFeedAxis]);

    return AppSettings.global(
      isOnboardingDone: isOnboardingDone ?? false,
      appTheme: appTheme,
      discoveryFeedAxis: discoveryFeedAxis,
    );
  }

  @override
  DbEntityMap toMap(AppSettings entity) => {
        AppSettingsFields.isOnboardingDone: entity.isOnboardingDone,
        AppSettingsFields.appTheme: _appThemeToIntMapper.map(entity.appTheme),
        AppSettingsFields.discoveryFeedAxis:
            _discoveryFeedAxisToIntMapper.map(entity.discoveryFeedAxis),
      };
}

abstract class AppSettingsFields {
  AppSettingsFields._();

  static const int isOnboardingDone = 0;
  static const int appTheme = 1;
  static const int discoveryFeedAxis = 2;
}
