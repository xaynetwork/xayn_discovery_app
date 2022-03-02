import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/premium/widgets/subscription_trial_banner.dart';

class SubscriptionSection extends StatelessWidget {
  final SubscriptionStatus subscriptionStatus;
  final VoidCallback onSubscribePressed;
  final Function(DateTime) onShowDetailsPressed;

  const SubscriptionSection({
    Key? key,
    required this.subscriptionStatus,
    required this.onSubscribePressed,
    required this.onShowDetailsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => subscriptionStatus.isTrialActive
      ? SettingsSection.custom(
          title: R.strings.settingsSectionSubscription,
          topPadding: 0,
          child: _buildTrialBanner(subscriptionStatus.trialEndDate!),
        )
      : SettingsSection(
          title: R.strings.settingsSectionSubscription,
          topPadding: 0,
          items: [_buildXaynPremium()],
        );

  SettingsCardData _buildXaynPremium() =>
      SettingsCardData.fromTile(SettingsTileData(
        title: R.strings.settingsXaynPremium,
        svgIconPath: R.assets.icons.diamond,
        action: SettingsTileActionIcon(
          key: Keys.settingsSubscriptionPremium,
          svgIconPath: R.assets.icons.arrowRight,
          onPressed: subscriptionStatus.isSubscriptionActive
              ? onShowDetailsPressed(subscriptionStatus.expirationDate!)
              : onSubscribePressed,
        ),
      ));

  Widget _buildTrialBanner(DateTime trialEndDate) => SubscriptionTrialBanner(
        trialEndDate: trialEndDate,
        onPressed: onSubscribePressed,
      );
}
