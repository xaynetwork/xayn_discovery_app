import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

import 'app_theme_mapper.dart';

@singleton
class AppSettingsMapper extends BaseDbEntityMapper<AppSettings> {
  final IntToAppThemeMapper _intToAppThemeMapper;
  final AppThemeToIntMapper _appThemeToIntMapper;

  const AppSettingsMapper(
    this._intToAppThemeMapper,
    this._appThemeToIntMapper,
  );

  @override
  AppSettings? fromMap(Map? map) {
    if (map == null) return null;

    final isOnboardingDone = map[AppSettingsFields.isOnboardingDone] as bool?;
    final appTheme = _intToAppThemeMapper.map(map[AppSettingsFields.appTheme]);

    return AppSettings.global(
      isOnboardingDone: isOnboardingDone ?? false,
      appTheme: appTheme,
    );
  }

  @override
  DbEntityMap toMap(AppSettings entity) => {
        AppSettingsFields.isOnboardingDone: entity.isOnboardingDone,
        AppSettingsFields.appTheme: _appThemeToIntMapper.map(entity.appTheme),
      };
}

abstract class AppSettingsFields {
  AppSettingsFields._();

  static const int isOnboardingDone = 0;
  static const int appTheme = 1;
}
