import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class ErrorBottomSheet extends BottomSheetBase {
  const ErrorBottomSheet({
    Key? key,
  }) : super(
          key: key,
          body: const _ErrorBottomSheet(),
        );
}

class _ErrorBottomSheet extends StatelessWidget with BottomSheetBodyMixin {
  const _ErrorBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final body = Text(R.strings.errorGenericBodyPleaseTryAgainLater);

    final header = BottomSheetHeader(
      headerText: R.strings.errorGenericHeaderSomethingWentWrong,
    );

    final closeButton = AppGhostButton.text(
      R.strings.errorClose,
      onPressed: () => closeBottomSheet(context),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        body,
        closeButton,
      ],
    );
  }
}
