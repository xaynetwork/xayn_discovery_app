import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class SettingsHelpImproveSection extends StatelessWidget {
  final VoidCallback onFindBugPressed;

  const SettingsHelpImproveSection({
    Key? key,
    required this.onFindBugPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsSection(
        title: R.strings.settingsSectionTitleHelpImprove,
        items: [_getFindBug()],
      );

  SettingsCardData _getFindBug() => SettingsCardData.fromTile(SettingsTileData(
        title: R.strings.settingsHaveFoundBug,
        svgIconPath: R.assets.icons.bug,
        action: SettingsTileActionIcon(
          key: Keys.settingsHaveFoundBug,
          svgIconPath: R.assets.icons.arrowRight,
          onPressed: onFindBugPressed,
        ),
      ));
}
