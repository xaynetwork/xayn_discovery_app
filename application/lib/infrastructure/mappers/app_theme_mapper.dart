import 'package:xayn_discovery_app/domain/model/app_theme.dart';

abstract class AppThemeFields {
  AppThemeFields._();

  static const int system = 0;
  static const int light = 1;
  static const int dark = 2;
}

extension AppThemeToInt on AppTheme {
  int toInt() {
    switch (this) {
      case AppTheme.light:
        return AppThemeFields.light;
      case AppTheme.dark:
        return AppThemeFields.dark;
      case AppTheme.system:
      default:
        return AppThemeFields.system;
    }
  }
}

extension IntToAppTheme on int {
  AppTheme toAppThemeEnum() {
    switch (this) {
      case AppThemeFields.light:
        return AppTheme.light;
      case AppThemeFields.dark:
        return AppTheme.dark;
      case AppThemeFields.system:
      default:
        return AppTheme.system;
    }
  }
}
