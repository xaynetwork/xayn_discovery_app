import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

/// Informative bottom sheet body has only title and body strings
/// and only one action button to close the bottom sheet
///
class BottomSheetInformationalBody extends StatelessWidget
    with BottomSheetBodyMixin {
  const BottomSheetInformationalBody({
    Key? key,
    required this.title,
    required this.body,
    this.errorCode,
  }) : super(key: key);

  final String title;
  final String body;
  final String? errorCode;

  @override
  Widget build(BuildContext context) {
    final bodyWidget = Text(body);

    final titleWidget = BottomSheetHeader(
      headerText: title,
    );

    final errorCodeWidget = Text(
      '(Error: ${errorCode ?? ''})',
      style: R.styles.sStyle.copyWith(
        color: R.colors.secondaryText,
      ),
    );

    final closeButton = AppGhostButton.text(
      R.strings.errorClose,
      onPressed: () => closeBottomSheet(context),
      backgroundColor: R.colors.bottomSheetCancelBackgroundColor,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: R.dimen.unit),
        titleWidget,
        SizedBox(height: R.dimen.unit1_25),
        bodyWidget,
        if (errorCode != null) errorCodeWidget,
        SizedBox(height: R.dimen.unit2_5),
        closeButton,
        SizedBox(height: R.dimen.unit3_5),
      ],
    );
  }
}
