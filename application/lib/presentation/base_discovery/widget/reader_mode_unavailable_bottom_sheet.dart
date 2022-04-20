import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class ReaderModeUnavailableBottomSheet extends BottomSheetBase {
  final VoidCallback? onOpenViaBrowser;
  final VoidCallback? onClosePressed;

  ReaderModeUnavailableBottomSheet({
    Key? key,
    this.onOpenViaBrowser,
    this.onClosePressed,
  }) : super(
          key: key,
          body: _ReaderModeUnavailable(
            onOpenViaBrowser: onOpenViaBrowser,
            onClosePressed: onClosePressed,
          ),
        );
}

class _ReaderModeUnavailable extends StatelessWidget with BottomSheetBodyMixin {
  final VoidCallback? onOpenViaBrowser;
  final VoidCallback? onClosePressed;

  const _ReaderModeUnavailable({
    this.onOpenViaBrowser,
    this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    final body = Text(R.strings.readerModeUnableToLoadDesc);
    final header = BottomSheetHeader(
      headerText: R.strings.readerModeUnableToLoadTitle,
    );

    onPressed() {
      closeBottomSheet(context);
      onOpenViaBrowser?.call();
    }

    final closeButton = AppGhostButton.text(
      R.strings.errorClose,
      onPressed: () {
        closeBottomSheet(context);
        if (onClosePressed != null) onClosePressed!();
      },
      backgroundColor: R.colors.bottomSheetCancelBackgroundColor,
    );
    final openViaBrowserButton = AppRaisedButton.text(
      text: R.strings.readerModeUnableToLoadCTA,
      onPressed: onPressed,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: R.dimen.unit),
        header,
        SizedBox(height: R.dimen.unit1_25),
        body,
        SizedBox(height: R.dimen.unit2_5),
        Row(
          children: [
            Expanded(child: closeButton),
            if (onOpenViaBrowser != null) ...[
              SizedBox(width: R.dimen.unit2),
              Expanded(child: openViaBrowserButton),
            ],
          ],
        ),
        SizedBox(height: R.dimen.unit),
      ],
    );
  }
}
