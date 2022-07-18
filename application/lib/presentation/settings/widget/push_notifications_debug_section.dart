import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class PushNotificationDebugSection extends StatelessWidget {
  final VoidCallback onRequestNotificationPermissionPressed;
  final VoidCallback onSendTestPushNotificationPressed;
  final VoidCallback onBackgroundProcessingPressed;

  const PushNotificationDebugSection({
    Key? key,
    required this.onRequestNotificationPermissionPressed,
    required this.onSendTestPushNotificationPressed,
    required this.onBackgroundProcessingPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: SettingsSection.custom(
          title: 'Push notifications',
          crossAxisAlignment: CrossAxisAlignment.center,
          child: Row(
            children: [
              _buildRequestNotificationBtn(),
              _buildSendNotificationBtn(),
              _buildBackgroundProcessingBtn(),
            ],
          ),
        ),
      );

  AppGhostButton _buildRequestNotificationBtn() => AppGhostButton.text(
        'Request',
        key: Keys.settingsRequestNotificationBtn,
        onPressed: onRequestNotificationPermissionPressed,
        backgroundColor: R.colors.iconBackground,
        textColor: R.colors.quaternaryText,
      );

  AppGhostButton _buildSendNotificationBtn() => AppGhostButton.text(
        'Send',
        key: Keys.settingsSendNotificationBtn,
        onPressed: onSendTestPushNotificationPressed,
        backgroundColor: R.colors.iconBackground,
        textColor: R.colors.quaternaryText,
      );

  AppGhostButton _buildBackgroundProcessingBtn() => AppGhostButton.text(
        'Background',
        key: Keys.settingsBackgroundProcessingBtn,
        onPressed: onBackgroundProcessingPressed,
        backgroundColor: R.colors.iconBackground,
        textColor: R.colors.quaternaryText,
      );
}
