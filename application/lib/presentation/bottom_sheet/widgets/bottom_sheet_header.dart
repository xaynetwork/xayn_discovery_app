import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class BottomSheetHeader extends StatelessWidget {
  const BottomSheetHeader({
    Key? key,
    this.actionWidget,
    required this.headerText,
  }) : super(key: key);

  final Widget? actionWidget;
  final String headerText;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(headerText, style: R.styles.appHeadlineText),
        actionWidget ?? const Spacer(),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: R.dimen.unit3),
      child: row,
    );
  }
}
