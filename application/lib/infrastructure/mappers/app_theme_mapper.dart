import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

const int _system = 0;
const int _light = 1;
const int _dark = 2;

@singleton
class IntToAppThemeMapper implements Mapper<int?, AppTheme> {
  const IntToAppThemeMapper();

  @override
  AppTheme map(int? input) {
    switch (input) {
      case _light:
        return AppTheme.light;
      case _dark:
        return AppTheme.dark;
      case _system:
      default:
        return AppTheme.system;
    }
  }
}

@singleton
class AppThemeToIntMapper implements Mapper<AppTheme, int> {
  const AppThemeToIntMapper();

  @override
  int map(AppTheme input) {
    switch (input) {
      case AppTheme.light:
        return _light;
      case AppTheme.dark:
        return _dark;
      case AppTheme.system:
      default:
        return _system;
    }
  }
}
