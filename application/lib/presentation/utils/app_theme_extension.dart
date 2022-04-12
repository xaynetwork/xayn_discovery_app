import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';

extension AppThemeExtension on AppTheme {
  Brightness get brightness =>
      computeBrightness(WidgetsBinding.instance!.window.platformBrightness);

  Brightness computeBrightness(Brightness platformBrightness) {
    switch (this) {
      case AppTheme.light:
        return Brightness.light;
      case AppTheme.dark:
        return Brightness.dark;
      case AppTheme.system:
      default:
        return platformBrightness;
    }
  }
}
