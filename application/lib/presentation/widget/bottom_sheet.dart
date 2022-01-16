import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

typedef _BottomSheetBuilder = BottomSheetBase Function(BuildContext context);

Future showXaynBottomSheet(BuildContext context,
    {required _BottomSheetBuilder builder}) {
  // todo: move to xayn_design
  const backgroundColor = Colors.white;
  final barrierColor = Colors.white.withOpacity(0.8);

  NavBarContainer.hideNavBar(context);

  return showMaterialModalBottomSheet(
    context: context,
    enableDrag: false,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
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
    final content = Padding(
      padding: widget.padding ??
          EdgeInsets.only(
            left: R.dimen.unit3,
            right: R.dimen.unit3,
            bottom: R.dimen.unit3,
            top: R.dimen.unit2,
          ),
      child: widget.body,
    );

    // todo: move to xayn_design
    const maxWidth = 480.0;

    final constrainedChild = LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: constraints.maxHeight * 0.9,
          maxWidth: maxWidth,
        ),
        child: content,
      ),
    );

    final bottomSheet = WillPopScope(
      onWillPop: () async {
        NavBarContainer.showNavBar(context);
        return true;
      },
      child: constrainedChild,
    );

    return bottomSheet;
  }
}

mixin BottomSheetBodyMixin {
  ScrollController? getScrollController(BuildContext context) =>
      ModalScrollController.of(context);

  void closeBottomSheet(BuildContext context) => Navigator.pop(context);
}
