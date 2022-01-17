import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';

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
      cancelBtnText ?? 'Cancel',
      onPressed: onCancelPressed,
    );
    final applyButton = AppRaisedButton.text(
      text: applyBtnText ?? 'Apply',
      onPressed: isApplyDisabled ? null : onApplyPressed,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        cancelButton,
        applyButton,
      ],
    );
  }
}
