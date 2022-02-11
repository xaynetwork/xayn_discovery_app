import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class SelectableChip extends StatelessWidget {
  SelectableChip.container({
    Key? key,
    Color? selectBackgroundColor,
    required Color color,
    Color? borderColor,
    this.isSelected = false,
    required this.onTap,
  })  : child = const SizedBox.shrink(),
        backgroundColor = color,
        padding = null,
        width = R.dimen.unit3_5,
        height = R.dimen.unit3_5,
        border = isSelected
            ? Border.all(
                color: R.colors.selectedItemBackgroundColor,
                width: R.dimen.unit0_5,
              )
            : borderColor != null
                ? Border.all(color: borderColor, width: R.dimen.unit0_25)
                : null,
        super(key: key);

  SelectableChip.svg({
    Key? key,
    Color? selectBackgroundColor,
    this.isSelected = false,
    EdgeInsets? padding,
    required String svgPath,
    required this.onTap,
  })  : child = SvgPicture.asset(
          svgPath,
          color: isSelected ? R.colors.iconInverse : R.colors.icon,
        ),
        backgroundColor =
            isSelected ? R.colors.selectedItemBackgroundColor : null,
        padding = padding ??
            EdgeInsets.symmetric(
              vertical: R.dimen.unit0_75,
              horizontal: R.dimen.unit1_75,
            ),
        width = null,
        height = null,
        border = null,
        super(key: key);

  final BoxBorder? border;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: R.styles.roundBorderBottomBarMenuSection,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: R.styles.roundBorder,
          border: border,
        ),
        child: child,
      ),
    );
  }
}
