import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

typedef _BottomSheetBuilder = BottomSheetBase Function(BuildContext context);

Future showAppBottomSheet(
  BuildContext context, {
  required _BottomSheetBuilder builder,
  bool showBarrierColor = true,
}) {
  NavBarContainer.hideNavBar(context);

  return showMaterialModalBottomSheet(
    context: context,
    enableDrag: false,
    shape: RoundedRectangleBorder(
      borderRadius: R.styles.roundBorderBottomSheet,
    ),
    backgroundColor: R.colors.bottomSheetBackgroundColor,
    barrierColor: showBarrierColor ? R.colors.bottomSheetBarrierColor : null,
    builder: builder,
  );
}

class BottomSheetBase extends StatefulWidget {
  const BottomSheetBase({
    Key? key,
    required this.body,
    this.padding,
  }) : super(key: key);

  final Widget body;
  final EdgeInsets? padding;

  @override
  _BottomSheetBaseState createState() => _BottomSheetBaseState();
}

class _BottomSheetBaseState extends State<BottomSheetBase> {
  @override
  Widget build(BuildContext context) {
    final paddedBody = Padding(
      padding: widget.padding ??
          EdgeInsets.symmetric(
            horizontal: R.dimen.unit3,
          ),
      child: widget.body,
    );

    final constrainedChild = LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: constraints.maxHeight * 0.9,
          maxWidth: R.dimen.bottomSheetMaxWidth,
        ),
        child: paddedBody,
      ),
    );

    final avoidKeyboardChild = Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: constrainedChild,
    );

    final bottomSheet = WillPopScope(
      onWillPop: () async {
        NavBarContainer.showNavBar(context);
        return true;
      },
      child: avoidKeyboardChild,
    );

    return bottomSheet;
  }
}

mixin BottomSheetBodyMixin {
  ScrollController? getScrollController(BuildContext context) =>
      ModalScrollController.of(context);

  void closeBottomSheet(BuildContext context) {
    Navigator.pop(context);
    NavBarContainer.showNavBar(context);
  }
}
