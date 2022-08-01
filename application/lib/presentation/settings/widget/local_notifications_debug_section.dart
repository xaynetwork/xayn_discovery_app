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
              SizedBox(width: R.dimen.unit),
              _buildSendLocalNotificationBtn(),
            ],
          ),
        ),
      );

  AppGhostButton _buildRequestLocalNotificationBtn() => AppGhostButton.text(
        'Request',
        key: Keys.settingsRequestLocalNotificationBtn,
        onPressed: onRequestLocalNotificationPermissionPressed,
        backgroundColor: R.colors.settingsCardBackground,
        textColor: R.colors.primaryText,
      );

  AppGhostButton _buildSendLocalNotificationBtn() => AppGhostButton.text(
        'Send',
        key: Keys.settingsSendLocalNotificationBtn,
        onPressed: onSendTestLocalNotificationPressed,
        backgroundColor: R.colors.settingsCardBackground,
        textColor: R.colors.primaryText,
      );
}
