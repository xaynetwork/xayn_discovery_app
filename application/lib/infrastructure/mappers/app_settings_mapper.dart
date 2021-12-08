import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/discovery_feed_axis.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/discovery_feed_axis_mapper.dart';

import 'app_theme_mapper.dart';

@singleton
class AppSettingsMapper extends BaseDbEntityMapper<AppSettings> {
  const AppSettingsMapper();

  @override
  AppSettings? fromMap(DbEntityMap? map) {
    if (map == null) return null;

    final isOnboardingDone = map[AppSettingsFields.isOnboardingDone] as bool?;
    final appThemeValue = map[AppSettingsFields.appTheme] as int?;
    final discoveryFeedAxisValue =
        map[AppSettingsFields.discoveryFeedAxis] as int?;

    return AppSettings.global(
      isOnboardingDone: isOnboardingDone ?? false,
      appTheme: appThemeValue?.toAppThemeEnum() ?? AppTheme.system,
      discoveryFeedAxis: discoveryFeedAxisValue?.toDiscoveryFeedAxisEnum() ??
          DiscoveryFeedAxis.vertical,
    );
  }

  @override
  DbEntityMap toMap(AppSettings entity) => {
        AppSettingsFields.isOnboardingDone: entity.isOnboardingDone,
        AppSettingsFields.appTheme: entity.appTheme.toInt(),
        AppSettingsFields.discoveryFeedAxis: entity.discoveryFeedAxis.toInt(),
      };
}

abstract class AppSettingsFields {
  AppSettingsFields._();

  static const int isOnboardingDone = 0;
  static const int appTheme = 1;
  static const int discoveryFeedAxis = 2;
}
