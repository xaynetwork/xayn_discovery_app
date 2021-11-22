import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

class ShareAppSection extends StatelessWidget {
  final VoidCallback onShareAppPressed;

  const ShareAppSection({
    Key? key,
    required this.onShareAppPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: SettingsSection.custom(
          title: Strings.settingsSectionTitleSpreadTheWord,
          child: _buildShareBtn(),
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
      );

  AppRaisedButton _buildShareBtn() => AppRaisedButton.textWithIcon(
        onPressed: onShareAppPressed,
        text: Strings.settingsShareBtn,
        svgIconPath: R.assets.icons.heart,
      );
}
