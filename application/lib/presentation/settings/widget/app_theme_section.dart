import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

typedef OnAppThemeSelected = Function(AppTheme theme);

class SettingsAppThemeSection extends StatelessWidget {
  final AppTheme theme;
  final OnAppThemeSelected onSelected;

  const SettingsAppThemeSection({
    Key? key,
    required this.theme,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsSection.custom(
        title: Strings.settingsSectionTitleAppTheme,
        topPadding: R.dimen.unit,
        child: SettingsSelectable.icons(
          items: AppTheme.values.map(_getItem).toList(),
        ),
      );

  SettingsSelectableData _getItem(AppTheme theme) => SettingsSelectableData(
        key: _getKey(theme),
        title: _getTitle(theme),
        svgIconPath: _getIcon(theme),
        isSelected: theme == this.theme,
        onPressed: () => onSelected(theme),
      );

  Key _getKey(AppTheme theme) {
    switch (theme) {
      case AppTheme.system:
        return Keys.settingsThemeSystem;
      case AppTheme.light:
        return Keys.settingsThemeLight;
      case AppTheme.dark:
        return Keys.settingsThemeDark;
    }
  }

  String _getTitle(AppTheme theme) {
    switch (theme) {
      case AppTheme.system:
        return Strings.settingsAppThemeSystem;
      case AppTheme.light:
        return Strings.settingsAppThemeLight;
      case AppTheme.dark:
        return Strings.settingsAppThemeDark;
    }
  }

  String _getIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.system:
        return R.assets.icons.moonAndSun;
      case AppTheme.light:
        return R.assets.icons.sun;
      case AppTheme.dark:
        return R.assets.icons.moon;
    }
  }
}
