import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar_data.dart';

import 'app_toolbar_trailing_button.dart';

class AppToolbar extends StatelessWidget implements PreferredSizeWidget {
  final AppToolbarData appToolbarData;

  const AppToolbar({
    Key? key,
    required this.appToolbarData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = '${R.strings.your} ${appToolbarData.yourTitle}';
    final text = Text(title, style: R.styles.appHeadlineText);
    final content = appToolbarData.map(
      titleOnly: (_) => text,
      withTrailingIcon: (data) => _buildWithTrailingIcon(
        text: text,
        iconPath: data.iconPath,
        onPressed: data.onPressed,
      ),
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.dimen.unit3,
          vertical: R.dimen.unit4,
        ),
        child: content,
      ),
    );
  }

  Widget _buildWithTrailingIcon({
    required Text text,
    required String iconPath,
    VoidCallback? onPressed,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text,
          AppToolbarTrailingIconButton(
            iconPath: iconPath,
            onPressed: onPressed,
          ),
        ],
      );

  @override
  Size get preferredSize => Size.fromHeight(R.dimen.unit12);
}

class TrailingIcon {
  final String icon;
  final VoidCallback? onPressed;

  TrailingIcon({required this.icon, this.onPressed});
}
