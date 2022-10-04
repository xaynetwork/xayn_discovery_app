import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class RemoteNotificationsDebugSection extends StatelessWidget {
  final VoidCallback onCopyChannelIdPressed;
  final VoidCallback onCopyUserIdPressed;

  const RemoteNotificationsDebugSection({
    Key? key,
    required this.onCopyChannelIdPressed,
    required this.onCopyUserIdPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: SettingsSection.custom(
          title: 'Remote notifications',
          crossAxisAlignment: CrossAxisAlignment.center,
          child: Row(
            children: [
              _buildCopyChannelIdBtn(),
              SizedBox(width: R.dimen.unit),
              _buildCopyUserIdBtn(),
            ],
          ),
        ),
      );

  AppGhostButton _buildCopyChannelIdBtn() => AppGhostButton.text(
        'Copy channel ID',
        key: Keys.settingsCopyChannelIdBtn,
        onPressed: onCopyChannelIdPressed,
        backgroundColor: R.colors.settingsCardBackground,
        textColor: R.colors.primaryText,
      );

  AppGhostButton _buildCopyUserIdBtn() => AppGhostButton.text(
        'Copy user ID',
        key: Keys.settingsCopyUserIdBtn,
        onPressed: onCopyUserIdPressed,
        backgroundColor: R.colors.settingsCardBackground,
        textColor: R.colors.primaryText,
      );
}
