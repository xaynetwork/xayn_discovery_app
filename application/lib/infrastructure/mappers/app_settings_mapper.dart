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

    final appTheme = _intToAppThemeMapper.map(map[AppSettingsFields.appTheme]);

    return AppSettings.global(
      appTheme: appTheme,
    );
  }

  @override
  DbEntityMap toMap(AppSettings entity) => {
        AppSettingsFields.appTheme: _appThemeToIntMapper.map(entity.appTheme),
      };
}

abstract class AppSettingsFields {
  AppSettingsFields._();

  static const int appTheme = 1;
}
