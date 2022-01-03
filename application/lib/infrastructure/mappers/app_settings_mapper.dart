import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/discovery_feed_axis_mapper.dart';

import 'app_theme_mapper.dart';

@singleton
class AppSettingsMapper extends BaseDbEntityMapper<AppSettings> {
  final IntToAppThemeMapper _intToAppThemeMapper;
  final AppThemeToIntMapper _appThemeToIntMapper;
  final IntToDiscoveryFeedAxisMapper _intToDiscoveryFeedAxisMapper;
  final DiscoveryFeedAxisToIntMapper _discoveryFeedAxisToIntMapper;
  final MapToAppVersionMapper _mapToAppVersionMapper;
  final AppVersionToMapMapper _appVersionToMapMapper;

  const AppSettingsMapper(
    this._intToAppThemeMapper,
    this._appThemeToIntMapper,
    this._intToDiscoveryFeedAxisMapper,
    this._discoveryFeedAxisToIntMapper,
    this._mapToAppVersionMapper,
    this._appVersionToMapMapper,
  );

  @override
  AppSettings? fromMap(Map? map) {
    if (map == null) return null;

    final isOnboardingDone = map[AppSettingsFields.isOnboardingDone] as bool?;
    final appTheme = _intToAppThemeMapper.map(map[AppSettingsFields.appTheme]);
    final discoveryFeedAxis = _intToDiscoveryFeedAxisMapper
        .map(map[AppSettingsFields.discoveryFeedAxis]);
    final numberOfSessions = map[AppSettingsFields.numberOfSessions] as int?;
    final appVersion =
        _mapToAppVersionMapper.map(map[AppSettingsFields.appVersion]);

    return AppSettings.global(
      isOnboardingDone: isOnboardingDone ?? false,
      appTheme: appTheme,
      discoveryFeedAxis: discoveryFeedAxis,
      numberOfSessions: numberOfSessions ?? 0,
      appVersion: appVersion ?? AppVersion.initial(),
    );
  }

  @override
  DbEntityMap toMap(AppSettings entity) => {
        AppSettingsFields.isOnboardingDone: entity.isOnboardingDone,
        AppSettingsFields.appTheme: _appThemeToIntMapper.map(entity.appTheme),
        AppSettingsFields.discoveryFeedAxis:
            _discoveryFeedAxisToIntMapper.map(entity.discoveryFeedAxis),
        AppSettingsFields.numberOfSessions: entity.numberOfSessions,
        AppSettingsFields.appVersion:
            _appVersionToMapMapper.map(entity.appVersion),
      };
}

abstract class AppSettingsFields {
  AppSettingsFields._();

  static const int isOnboardingDone = 0;
  static const int appTheme = 1;
  static const int discoveryFeedAxis = 2;
  static const int numberOfSessions = 3;
  static const int appVersion = 4;
}
