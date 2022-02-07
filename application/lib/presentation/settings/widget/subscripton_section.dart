import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class SubscriptionSection extends StatelessWidget {
  final DateTime? trialEndDate;
  final VoidCallback onSubscribePressed;

  const SubscriptionSection({
    Key? key,
    required this.trialEndDate,
    required this.onSubscribePressed,
  }) : super(key: key);

  bool get _showTrialBanner => trialEndDate?.isAfter(DateTime.now()) ?? false;

  @override
  Widget build(BuildContext context) => _showTrialBanner
      ? SettingsSection.custom(
          title: R.strings.settingsSectionSubscription,
          topPadding: 0,
          child: _buildTrialBanner(),
        )
      : SettingsSection(
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

  Widget _buildTrialBanner() => Container(
        height: 80,
      );
}
