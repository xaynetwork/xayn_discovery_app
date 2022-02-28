import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class SelectableChip extends StatelessWidget {
  SelectableChip.container({
    Key? key,
    required Color color,
    required this.onTap,
    Color? borderColor,
    this.isSelected = false,
  })  : child = const SizedBox.shrink(),
        backgroundColor = color,
        padding = null,
        width = isSelected ? R.dimen.unit3_5 : R.dimen.unit3_25,
        height = isSelected ? R.dimen.unit3_5 : R.dimen.unit3_25,
        border = isSelected
            ? Border.all(
                color: R.colors.selectedItemBackgroundColor,
                width: R.dimen.unit0_5,
              )
            : Border.all(
                color: borderColor ?? R.colors.chipBorderColor,
                width: R.dimen.unit0_25,
              ),
        super(key: key);

  SelectableChip.svg({
    Key? key,
    required String svgPath,
    required this.onTap,
    this.isSelected = false,
    EdgeInsets? padding,
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
      child: Ink(
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
