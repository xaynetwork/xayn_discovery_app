import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class RemoteNotificationsDebugSection extends StatelessWidget {
  final VoidCallback onRequestRemoteNotificationPermissionPressed;
  final VoidCallback onCopyChannelIdPressed;

  const RemoteNotificationsDebugSection({
    Key? key,
    required this.onRequestRemoteNotificationPermissionPressed,
    required this.onCopyChannelIdPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: SettingsSection.custom(
          title: 'Remote notifications',
          crossAxisAlignment: CrossAxisAlignment.center,
          child: Row(
            children: [
              _buildRequestRemoteNotificationBtn(),
              SizedBox(width: R.dimen.unit),
              _buildCopyChannelIdBtn(),
            ],
          ),
        ),
      );

  AppGhostButton _buildRequestRemoteNotificationBtn() => AppGhostButton.text(
        'Request',
        key: Keys.settingsRequestRemoteNotificationBtn,
        onPressed: onRequestRemoteNotificationPermissionPressed,
        backgroundColor: R.colors.settingsCardBackground,
        textColor: R.colors.primaryText,
      );

  AppGhostButton _buildCopyChannelIdBtn() => AppGhostButton.text(
        'Copy channel ID',
        key: Keys.settingsCopyChannelIdBtn,
        onPressed: onCopyChannelIdPressed,
        backgroundColor: R.colors.settingsCardBackground,
        textColor: R.colors.primaryText,
      );
}
