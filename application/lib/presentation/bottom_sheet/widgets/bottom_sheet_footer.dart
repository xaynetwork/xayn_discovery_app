import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer_data.dart';
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

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: cancelButton,
        ),
        SizedBox(
          width: R.dimen.unit0_5,
        ),
        ..._buildRaisedButtons(),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: R.dimen.unit2),
      child: row,
    );
  }

  List<Widget> _buildRaisedButtons() => setup.map(
        withOneRaisedButton: (it) =>
            [Expanded(child: _buildRaisedButton(it.buttonData))],
        withTwoRaisedButtons: (it) => _buildTwoRaisedButtons(it.buttonsData),
      );

  List<Widget> _buildTwoRaisedButtons(
          List<BottomSheetFooterButton> buttonsData) =>
      [
        Expanded(
          child: _buildRaisedButton(
            buttonsData[0],
          ),
          flex: 2,
        ),
        SizedBox(
          width: R.dimen.unit0_5,
        ),
        Expanded(
          child: _buildRaisedButton(
            buttonsData[1],
          ),
          flex: 2,
        ),
      ];

  Widget _buildRaisedButton(BottomSheetFooterButton buttonData) =>
      AppRaisedButton.text(
        text: buttonData.text,
        onPressed: buttonData.isDisabled ? null : buttonData.onPressed,
      );
}
