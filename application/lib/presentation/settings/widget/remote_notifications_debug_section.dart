import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class RemoteNotificationsDebugSection extends StatelessWidget {
  final VoidCallback onRequestRemoteNotificationPermissionPressed;

  const RemoteNotificationsDebugSection({
    Key? key,
    required this.onRequestRemoteNotificationPermissionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: SettingsSection.custom(
          title: 'Remote notifications',
          crossAxisAlignment: CrossAxisAlignment.center,
          child: Row(
            children: [
              _buildRequestRemoteNotificationBtn(),
            ],
          ),
        ),
      );

  AppGhostButton _buildRequestRemoteNotificationBtn() => AppGhostButton.text(
        'Request',
        key: Keys.settingsRequestRemoteNotificationBtn,
        onPressed: onRequestRemoteNotificationPermissionPressed,
        backgroundColor: R.colors.iconBackground,
        textColor: R.colors.quaternaryText,
      );
}
