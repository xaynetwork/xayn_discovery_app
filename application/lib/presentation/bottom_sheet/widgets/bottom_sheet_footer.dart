import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class BottomSheetFooter extends StatelessWidget {
  const BottomSheetFooter({
    Key? key,
    required this.onCancelPressed,
    required this.onApplyPressed,
    this.cancelBtnText,
    this.applyBtnText,
    this.isApplyDisabled = false,
  }) : super(key: key);

  final VoidCallback onCancelPressed;
  final VoidCallback onApplyPressed;
  final String? cancelBtnText;
  final String? applyBtnText;
  final bool isApplyDisabled;

  @override
  Widget build(BuildContext context) {
    final cancelButton = AppGhostButton.text(
      cancelBtnText ?? R.strings.bottomSheetCancel,
      onPressed: onCancelPressed,
    );
    final applyButton = AppRaisedButton.text(
      text: applyBtnText ?? R.strings.bottomSheetApply,
      onPressed: isApplyDisabled ? null : onApplyPressed,
    );

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: cancelButton),
        Expanded(child: applyButton),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: R.dimen.unit2),
      child: row,
    );
  }
}
