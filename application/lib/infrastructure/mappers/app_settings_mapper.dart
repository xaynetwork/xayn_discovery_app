import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/discovery_feed_axis_mapper.dart';

import 'app_theme_mapper.dart';

class AppSettingsMapper extends BaseMapper<AppSettings> {
  const AppSettingsMapper();

  @override
  AppSettings? fromMap(Map? map) {
    if (map == null) return null;

    final appThemeValue =
        map[AppSettingsFields.appTheme] as int? ?? AppThemeFields.system;
    final discoveryFeedAxisValue =
        map[AppSettingsFields.discoveryFeedAxis] as int? ??
            DiscoveryFeedAxisFields.vertical;

    return AppSettings(
      isOnboardingDone:
          map[AppSettingsFields.isOnboardingDone] as bool? ?? false,
      appTheme: appThemeValue.toAppThemeEnum(),
      discoveryFeedAxis: discoveryFeedAxisValue.toDiscoveryFeedAxisEnum(),
    );
  }

  @override
  Map toMap(AppSettings entity) {
    return {
      AppSettingsFields.isOnboardingDone: entity.isOnboardingDone,
      AppSettingsFields.appTheme: entity.appTheme.toInt(),
      AppSettingsFields.discoveryFeedAxis: entity.discoveryFeedAxis.toInt(),
    };
  }
}

class AppSettingsFields {
  static const int isOnboardingDone = 1;
  static const int appTheme = 2;
  static const int discoveryFeedAxis = 3;
}
