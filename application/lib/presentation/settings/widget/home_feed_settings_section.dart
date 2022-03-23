import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class SettingsHomeFeedSection extends StatelessWidget {
  final VoidCallback onCountriesPressed;

  const SettingsHomeFeedSection({
    Key? key,
    required this.onCountriesPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsSection(
        title: R.strings.settingsSectionHomeFeed,
        items: [_buildCountriesOption()],
      );

  SettingsCardData _buildCountriesOption() =>
      SettingsCardData.fromTile(SettingsTileData(
        title: R.strings.feedSettingsScreenTabCountries,
        svgIconPath: R.assets.icons.speechBubbles,
        action: SettingsTileActionIcon(
          key: Keys.settingsCountriesOption,
          svgIconPath: R.assets.icons.arrowRight,
          onPressed: onCountriesPressed,
        ),
      ));
}
