import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class SettingsGeneralInfoSection extends StatelessWidget {
  final VoidCallback onAboutPressed;
  final VoidCallback onCarbonNeutralPressed;
  final VoidCallback onImprintPressed;
  final VoidCallback onPrivacyPressed;
  final VoidCallback onTermsPressed;
  final VoidCallback? onPaymentPressed;

  const SettingsGeneralInfoSection({
    Key? key,
    required this.onAboutPressed,
    required this.onCarbonNeutralPressed,
    required this.onImprintPressed,
    required this.onPrivacyPressed,
    required this.onTermsPressed,
    required this.onPaymentPressed,
  }) : super(key: key);

  String get arrowRightIcon => R.assets.icons.arrowRight;

  @override
  Widget build(BuildContext context) => SettingsSection(
        title: R.strings.settingsSectionTitleGeneralInfo,
        items: [
          _getAboutXayn(),
          _getCarbonNeutral(),
          _getImprint(),
          _getPrivacyPolicy(),
          _getTC(),
          if (onPaymentPressed != null) _getPayment(),
        ],
      );

  SettingsCardData _getAboutXayn() =>
      SettingsCardData.fromTile(SettingsTileData(
        title: R.strings.settingsAboutXayn,
        svgIconPath: R.assets.icons.info,
        action: SettingsTileActionIcon(
          key: Keys.settingsAboutXayn,
          svgIconPath: arrowRightIcon,
          onPressed: onAboutPressed,
        ),
      ));

  SettingsCardData _getCarbonNeutral() =>
      SettingsCardData.fromTile(SettingsTileData(
        title: R.strings.settingsCarbonNeutral,
        svgIconPath: R.assets.icons.plant,
        action: SettingsTileActionIcon(
          key: Keys.settingsCarbonNeutral,
          svgIconPath: arrowRightIcon,
          onPressed: onCarbonNeutralPressed,
        ),
      ));

  SettingsCardData _getImprint() => SettingsCardData.fromTile(SettingsTileData(
        title: R.strings.settingsImprint,
        svgIconPath: R.assets.icons.legal,
        action: SettingsTileActionIcon(
          key: Keys.settingsImprint,
          svgIconPath: arrowRightIcon,
          onPressed: onImprintPressed,
        ),
      ));

  SettingsCardData _getPrivacyPolicy() =>
      SettingsCardData.fromTile(SettingsTileData(
        title: R.strings.settingsPrivacyPolicy,
        svgIconPath: R.assets.icons.legal,
        action: SettingsTileActionIcon(
          key: Keys.settingsPrivacyPolicy,
          svgIconPath: arrowRightIcon,
          onPressed: onPrivacyPressed,
        ),
      ));

  SettingsCardData _getTC() => SettingsCardData.fromTile(SettingsTileData(
        title: R.strings.settingsTermsAndConditions,
        svgIconPath: R.assets.icons.legal,
        action: SettingsTileActionIcon(
          key: Keys.settingsTermsAndConditions,
          svgIconPath: arrowRightIcon,
          onPressed: onTermsPressed,
        ),
      ));

  SettingsCardData _getPayment() => SettingsCardData.fromTile(SettingsTileData(
        title: 'PAYMENT WIP',
        svgIconPath: R.assets.icons.lightening,
        action: SettingsTileActionIcon(
          key: const Key('payment key'),
          svgIconPath: arrowRightIcon,
          onPressed: onPaymentPressed!,
        ),
      ));
}
