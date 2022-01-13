import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

showXaynBottomSheet(BuildContext context, {required BottomSheetWidget child}) {
  final scrollableBody = Flexible(
    child: SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: child.body,
    ),
  );

  final headerAndBody = Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [child.header, scrollableBody],
  );

  final constrainedChild = LayoutBuilder(
    builder: (context, constraints) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: constraints.maxHeight * 0.9,
      ),
      child: headerAndBody,
    ),
  );

  // todo: move to xayn_design
  const backgroundColor = Colors.white;
  final barrierColor = Colors.white.withOpacity(0.4);

  return showCupertinoModalBottomSheet(
    context: context,
    enableDrag: false,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    builder: (context) => constrainedChild,
  );
}

mixin BottomSheetMixin implements BottomSheetWidget {
  @override
  Widget get header => Container();
}

abstract class BottomSheetWidget {
  Widget get header;

  Widget get body;
}
