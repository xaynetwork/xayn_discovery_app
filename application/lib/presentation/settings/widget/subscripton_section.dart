import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class SubscriptionSection extends StatelessWidget {
  final VoidCallback onSubscribePressed;

  const SubscriptionSection({
    Key? key,
    required this.onSubscribePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsSection(
        title: R.strings.settingsSectionSubscription,
        topPadding: 0,
        items: [
          _getXaynPremium(),
        ],
      );

  SettingsCardData _getXaynPremium() =>
      SettingsCardData.fromTile(SettingsTileData(
        title: R.strings.settingsXaynPremium,
        svgIconPath: R.assets.icons.diamond,
        action: SettingsTileActionIcon(
          key: Keys.settingsSubscriptionPremium,
          svgIconPath: R.assets.icons.arrowRight,
          onPressed: onSubscribePressed,
        ),
      ));
}
