import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class LocalNotificationsDebugSection extends StatelessWidget {
  final VoidCallback onRequestLocalNotificationPermissionPressed;
  final VoidCallback onSendTestLocalNotificationPressed;

  const LocalNotificationsDebugSection({
    Key? key,
    required this.onRequestLocalNotificationPermissionPressed,
    required this.onSendTestLocalNotificationPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: SettingsSection.custom(
          title: 'Local notifications',
          crossAxisAlignment: CrossAxisAlignment.center,
          child: Row(
            children: [
              _buildRequestLocalNotificationBtn(),
              _buildSendLocalNotificationBtn(),
            ],
          ),
        ),
      );

  AppGhostButton _buildRequestLocalNotificationBtn() => AppGhostButton.text(
        'Request',
        key: Keys.settingsRequestLocalNotificationBtn,
        onPressed: onRequestLocalNotificationPermissionPressed,
        backgroundColor: R.colors.iconBackground,
        textColor: R.colors.quaternaryText,
      );

  AppGhostButton _buildSendLocalNotificationBtn() => AppGhostButton.text(
        'Send',
        key: Keys.settingsSendLocalNotificationBtn,
        onPressed: onSendTestLocalNotificationPressed,
        backgroundColor: R.colors.iconBackground,
        textColor: R.colors.quaternaryText,
      );
}
