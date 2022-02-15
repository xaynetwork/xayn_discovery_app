import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class BottomSheetFooter extends StatelessWidget {
  const BottomSheetFooter({
    Key? key,
    required this.onCancelPressed,
    required this.setup,
    this.cancelBtnText,
  }) : super(key: key);

  final BottomSheetFooterSetup setup;
  final VoidCallback onCancelPressed;
  final String? cancelBtnText;

  @override
  Widget build(BuildContext context) {
    final cancelButton = AppGhostButton.text(
      cancelBtnText ?? R.strings.bottomSheetCancel,
      onPressed: onCancelPressed,
    );

    final buttonsDisposal = setup.map(
      row: (it) => _buildRow(
        cancelButton,
        it.buttonData,
      ),
      column: (it) => _buildColumn(
        cancelButton,
        it.buttonsData,
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: R.dimen.unit2),
      child: buttonsDisposal,
    );
  }

  Widget _buildRow(Widget cancelButton, BottomSheetFooterButton buttonData) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: cancelButton,
          ),
          SizedBox(
            width: R.dimen.unit0_5,
          ),
          Expanded(
            child: _buildRaisedButton(buttonData),
          ),
        ],
      );

  Widget _buildColumn(
          Widget cancelButton, List<BottomSheetFooterButton> buttonsData) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRaisedButton(buttonsData[0]),
          SizedBox(
            height: R.dimen.unit0_5,
          ),
          _buildRaisedButton(buttonsData[1]),
          SizedBox(
            height: R.dimen.unit0_5,
          ),
          cancelButton,
        ],
      );

  Widget _buildRaisedButton(BottomSheetFooterButton buttonData) =>
      AppRaisedButton.text(
        text: buttonData.text,
        onPressed: buttonData.isDisabled ? null : buttonData.onPressed,
      );
}
