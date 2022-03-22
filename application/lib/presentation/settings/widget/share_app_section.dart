import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class ShareAppSection extends StatelessWidget {
  final VoidCallback onShareAppPressed;

  const ShareAppSection({
    Key? key,
    required this.onShareAppPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: SettingsSection.custom(
          title: R.strings.settingsSectionTitleSpreadTheWord,
          child: _buildShareBtn(),
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      );

  AppGhostButton _buildShareBtn() => AppGhostButton.textWithIcon(
        key: Keys.settingsShareBtn,
        onPressed: onShareAppPressed,
        text: R.strings.settingsShareBtn,
        svgIconPath: R.assets.icons.heart,
        backgroundColor: R.colors.primaryAction,
        iconColor: R.colors.iconInverse,
        textColor: R.colors.quaternaryText,
      );
}
