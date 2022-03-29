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

  @override
  Widget build(BuildContext context) => Scrollbar(
        controller: scrollController,
        thickness: R.dimen.unit0_5,
        radius: Radius.circular(R.dimen.unit0_5),
        isAlwaysShown: scrollController.hasClients,
        child: child,
      );
}
