import 'package:flutter/material.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_design/xayn_design.dart';

typedef _NavBarReset = Function(
  BuildContext context, {
  required bool goingBack,
});

class NavBarObserver extends xayn.NavigatorDelegateObserver {
  final _NavBarReset _navBarReset;

  NavBarObserver() : _navBarReset = NavBarContainer.resetNavBar;

  @visibleForTesting
  NavBarObserver.test(_NavBarReset navBarReset) : _navBarReset = navBarReset;

  @override
  void didChangeState(
    BuildContext context,
    xayn.NavigatorState? oldState,
    xayn.NavigatorState newState,
  ) {
    _resetNavBarConfig(context, isGoingBack: false);
    super.didChangeState(context, oldState, newState);
  }

  @override
  void didPop(BuildContext context) =>
      _resetNavBarConfig(context, isGoingBack: true);

  void _resetNavBarConfig(
    BuildContext context, {
    required bool isGoingBack,
  }) {
    _navBarReset(context, goingBack: isGoingBack);
  }
}
