import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class NotificationsSection extends StatelessWidget {
  final VoidCallback togglePushNotificationsState;
  final bool arePushNotificationsActive;

  const NotificationsSection({
    Key? key,
    required this.togglePushNotificationsState,
    required this.arePushNotificationsActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SettingsSection(
        title: R.strings.settingsSectionTitleNotifications,
        items: [_buildActivatePushNotifications()],
      );

  SettingsCardData _buildActivatePushNotifications() =>
      SettingsCardData.fromTile(
        SettingsTileData(
          title: R.strings.activatePushNotifications,
          svgIconPath: R.assets.icons.info,
          action: SettingsTileActionSwitch(
            key: Keys.settingsAboutXayn,
            value: arePushNotificationsActive,
            onPressed: togglePushNotificationsState,
          ),
        ),
      );
}
