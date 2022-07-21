import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_button_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/model/bottom_sheet_footer/bottom_sheet_footer_data.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_footer.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class ResetAIBottomSheet extends BottomSheetBase {
  ResetAIBottomSheet({
    Key? key,
    VoidCallback? onSystemPop,
    required VoidCallback onResetAIPressed,
  }) : super(
          key: key,
          body: _ResetAI(
            onSystemPop: onSystemPop,
            onResetAIPressed: onResetAIPressed,
          ),
        );
}

class _ResetAI extends StatefulWidget {
  const _ResetAI({
    Key? key,
    this.onSystemPop,
    required this.onResetAIPressed,
  }) : super(
          key: key,
        );

  final VoidCallback onResetAIPressed;
  final VoidCallback? onSystemPop;

  @override
  State<_ResetAI> createState() => __ResetAIState();
}

class __ResetAIState extends State<_ResetAI> with BottomSheetBodyMixin {
  @override
  Widget build(BuildContext context) {
    final header = Padding(
      padding: EdgeInsets.symmetric(vertical: R.dimen.unit),
      child: BottomSheetHeader(
        headerText: R.strings.bottomSheetResetAIHeader,
      ),
    );

    final body = Text(R.strings.bottomSheetResetAIBody);

    final footer = BottomSheetFooter(
      onCancelPressed: () {
        closeBottomSheet(context);
        widget.onSystemPop?.call();
      },
      setup: _buildFooterSetup,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        body,
        footer,
      ],
    );
  }

  BottomSheetFooterSetup get _buildFooterSetup => BottomSheetFooterSetup.column(
        buttonsData: [
          BottomSheetFooterButton(
            text: R.strings.bottomSheetResetAIButton,
            onPressed: () {
              widget.onResetAIPressed();
              closeBottomSheet(context);
            },
          )
        ],
      );
}
