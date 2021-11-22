import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';

class YourToolbar extends StatelessWidget implements PreferredSizeWidget {
  final String yourTitle;

  const YourToolbar({
    Key? key,
    required this.yourTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = R.styles.appHeadlineText!;
    final text = TextSpan(
      style: style,
      children: [
        TextSpan(text: Strings.your),
        const TextSpan(text: ' '),
        TextSpan(
          text: yourTitle,
          style: style.copyWith(color: R.colors.accent),
        ),
      ],
    );
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.dimen.unit3,
          vertical: R.dimen.unit4,
        ),
        child: RichText(text: text),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(R.dimen.unit12);
}
