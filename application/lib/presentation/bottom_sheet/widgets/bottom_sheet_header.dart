import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class BottomSheetHeader extends StatelessWidget {
  const BottomSheetHeader({
    Key? key,
    this.actionWidget,
    this.align = TextAlign.center,
    required this.headerText,
  }) : super(key: key);

  final TextAlign align;
  final Widget? actionWidget;
  final String headerText;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      headerText,
      style: R.styles.lBoldStyle,
      textAlign: align,
    );
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: text),
        actionWidget ?? const SizedBox(),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: R.dimen.unit0_75,
      ),
      child: row,
    );
  }
}
