import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class CardMenuIndicator extends StatelessWidget {
  final bool isInteractionEnabled;
  final VoidCallback onOpenHeaderMenu;

  const CardMenuIndicator({
    Key? key,
    required this.isInteractionEnabled,
    required this.onOpenHeaderMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    maybeWithTap(Widget child, VoidCallback onTap) => Material(
          color: R.colors.transparent,
          child: InkWell(
            onTap: isInteractionEnabled ? onTap : null,
            child: child,
          ),
        );

    final openUrlIcon = ClipRRect(
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(R.dimen.unit3),
          bottomRight: Radius.circular(R.dimen.unit3),
          topLeft: Radius.circular(R.dimen.unit3),
          topRight: Radius.circular(R.dimen.unit3)),
      child: ColoredBox(
        color: R.colors.background,
        child: Padding(
          padding: EdgeInsets.all(R.dimen.unit),
          child: SvgPicture.asset(
            R.assets.icons.more,
            color: R.colors.icon,
          ),
        ),
      ),
    );

    return maybeWithTap(openUrlIcon, onOpenHeaderMenu);
  }
}
