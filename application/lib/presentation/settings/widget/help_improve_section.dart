import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class SettingsHelpImproveSection extends StatelessWidget {
  final VoidCallback onReportBugPressed;
  final VoidCallback onGiveFeedbackPressed;

  const SettingsHelpImproveSection({
    Key? key,
    required this.onReportBugPressed,
    required this.onGiveFeedbackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsSection(
        title: R.strings.settingsSectionTitleHelpImprove,
        items: [
          _getGiveFeedback(),
          _getFindBug(),
        ],
      );

  SettingsCardData _getFindBug() => SettingsCardData.fromTile(
        SettingsTileData(
          title: R.strings.settingsHaveFoundBug,
          svgIconPath: R.assets.icons.bug,
          action: SettingsTileActionIcon(
            key: Keys.settingsHaveFoundBug,
            svgIconPath: R.assets.icons.arrowRight,
            onPressed: onReportBugPressed,
          ),
        ),
      );

  SettingsCardData _getGiveFeedback() => SettingsCardData.fromTile(
        SettingsTileData(
          title: R.strings.settingsGiveFeedback,
          svgIconPath: R.assets.icons.speechBubbles,
          action: SettingsTileActionIcon(
            key: Keys.settingsGiveFeedback,
            svgIconPath: R.assets.icons.arrowRight,
            onPressed: onGiveFeedbackPressed,
          ),
        ),
      );
}
