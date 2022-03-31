import 'package:flutter/widgets.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/widgets/bottom_sheet_header.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class ReaderModeUnavailableBottomSheet extends BottomSheetBase {
  final VoidCallback? onOpenViaBrowser;

  ReaderModeUnavailableBottomSheet({
    Key? key,
    this.onOpenViaBrowser,
  }) : super(
          key: key,
          body: _ReaderModeUnavailable(onOpenViaBrowser: onOpenViaBrowser),
        );
}

class _ReaderModeUnavailable extends StatelessWidget with BottomSheetBodyMixin {
  final VoidCallback? onOpenViaBrowser;

  const _ReaderModeUnavailable({this.onOpenViaBrowser});

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

    final closeButton = AppRaisedButton.text(
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
        closeButton,
        SizedBox(height: R.dimen.unit3_5),
      ],
    );
  }
}
