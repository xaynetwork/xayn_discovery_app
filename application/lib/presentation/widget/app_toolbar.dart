import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

class AppToolbar extends StatelessWidget implements PreferredSizeWidget {
  final String yourTitle;

  const AppToolbar({
    Key? key,
    required this.yourTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = '${Strings.your} $yourTitle';
    final text = Text(title, style: R.styles.appHeadlineText);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.dimen.unit3,
          vertical: R.dimen.unit4,
        ),
        child: text,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(R.dimen.unit12);
}
