import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class SettingsHomeFeedSection extends StatelessWidget {
  final VoidCallback onTopicsPressed;
  final VoidCallback onSourcesPressed;
  final VoidCallback onCountriesPressed;
  final VoidCallback onResetAIPressed;
  final bool isFirstSection;

  const SettingsHomeFeedSection({
    Key? key,
    required this.onTopicsPressed,
    required this.onSourcesPressed,
    required this.onCountriesPressed,
    required this.onResetAIPressed,
    this.isFirstSection = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsSection(
        title: R.strings.settingsSectionHomeFeed,
        topPadding: isFirstSection ? 0 : R.dimen.unit3,
        items: [
          _buildTopicsOption(),
          _buildSourcesOption(),
          _buildCountriesOption(),
          _buildResetAIOption(),
        ],
      );

  SettingsCardData _buildTopicsOption() => SettingsCardData.fromTile(
        SettingsTileData(
          title: R.strings.feedSettingsScreenTabTopics,
          svgIconPath: R.assets.icons.readerMode,
          action: SettingsTileActionIcon(
            key: Keys.settingsTopicsOption,
            svgIconPath: R.assets.icons.arrowRight,
            onPressed: onTopicsPressed,
          ),
        ),
      );

  SettingsCardData _buildSourcesOption() => SettingsCardData.fromTile(
        SettingsTileData(
          title: R.strings.feedSettingsScreenTabSources,
          svgIconPath: R.assets.icons.news,
          action: SettingsTileActionIcon(
            key: Keys.settingsSourcesOption,
            svgIconPath: R.assets.icons.arrowRight,
            onPressed: onSourcesPressed,
          ),
        ),
      );

  SettingsCardData _buildCountriesOption() => SettingsCardData.fromTile(
        SettingsTileData(
          title: R.strings.feedSettingsScreenTabCountries,
          svgIconPath: R.assets.icons.speechBubbles,
          action: SettingsTileActionIcon(
            key: Keys.settingsCountriesOption,
            svgIconPath: R.assets.icons.arrowRight,
            onPressed: onCountriesPressed,
          ),
        ),
      );

  SettingsCardData _buildResetAIOption() => SettingsCardData.fromTile(
        SettingsTileData(
          title: R.strings.feedSettingsScreenResetAIOption,
          svgIconPath: R.assets.icons.brainy,
          action: SettingsTileActionIcon(
            key: Keys.settingsResetAIOption,
            svgIconPath: R.assets.icons.arrowRight,
            onPressed: onResetAIPressed,
          ),
        ),
      );
}
