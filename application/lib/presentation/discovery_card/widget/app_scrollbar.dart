import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

class AppScrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController scrollController;

  const AppScrollbar({
    Key? key,
    required this.child,
    required this.scrollController,
  }) : super(key: key);

  /// ScrollbarPainter relies on MediaQuery.padding, instead of the current Layout context,
  /// therefore, we reset this padding.
  /// If not, the scroll bar does not render on the full height.
  @override
  Widget build(BuildContext context) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: Scrollbar(
          controller: scrollController,
          thickness: R.dimen.unit0_5,
          radius: Radius.circular(R.dimen.unit0_5),
          thumbVisibility: scrollController.hasClients,
          child: child,
        ),
      );
}
