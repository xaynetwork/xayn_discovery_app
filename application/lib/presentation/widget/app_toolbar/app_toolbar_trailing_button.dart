import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class AppToolbarTrailingIconButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback? onPressed;
  final Key? iconKey;

  const AppToolbarTrailingIconButton({
    required this.iconPath,
    this.onPressed,
    this.iconKey,
    Key? key,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      iconPath,
      width: R.dimen.iconSize,
      height: R.dimen.iconSize,
      color: R.colors.icon,
    );
    final btn = InkWell(
      key: iconKey,
      onTap: onPressed,
      child: Center(child: icon),
      borderRadius: BorderRadius.circular(R.dimen.unit),
    );

    return SizedBox(
      child: btn,
      height: R.dimen.unit4,
      width: R.dimen.unit4,
    );
  }
}
