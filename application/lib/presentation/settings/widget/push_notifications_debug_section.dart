import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class PushNotificationDebugSection extends StatelessWidget {
  final VoidCallback onRequestNotificationPermissionPressed;
  final VoidCallback onSendTestPushNotificationPressed;

  const PushNotificationDebugSection({
    Key? key,
    required this.onRequestNotificationPermissionPressed,
    required this.onSendTestPushNotificationPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: SettingsSection.custom(
          title: R.strings.settingsSectionTitleSpreadTheWord,
          crossAxisAlignment: CrossAxisAlignment.center,
          child: Row(
            children: [
              _buildRequestNotificationBtn(),
              _buildSendNotificationBtn(),
            ],
          ),
        ),
      );

  AppGhostButton _buildRequestNotificationBtn() => AppGhostButton.textWithIcon(
        key: Keys.settingsRequestNotificationBtn,
        onPressed: onRequestNotificationPermissionPressed,
        text: 'Request',
        svgIconPath: R.assets.icons.info,
        backgroundColor: R.colors.iconBackground,
        iconColor: R.colors.iconInverse,
        textColor: R.colors.quaternaryText,
      );

  AppGhostButton _buildSendNotificationBtn() => AppGhostButton.textWithIcon(
        key: Keys.settingsSendNotificationBtn,
        onPressed: onSendTestPushNotificationPressed,
        text: 'Send',
        svgIconPath: R.assets.icons.devices,
        backgroundColor: R.colors.iconBackground,
        iconColor: R.colors.iconInverse,
        textColor: R.colors.quaternaryText,
      );
}
