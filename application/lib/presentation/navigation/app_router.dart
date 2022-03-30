import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_design/xayn_design.dart' hide NavBarObserver;
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/navigation/observer/nav_bar_observer.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/messages.dart';

const double kExtraBottomOffset = 18.0;

class AppRouter extends xayn.NavigatorDelegate {
  AppRouter(AppNavigationManager navigationManager) : super(navigationManager);

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context);
    final isKeyboardVisible = mQuery.viewInsets.bottom > 0;
    // The purpose to the extra bottom padding is to align the navbar
    // so that it's in the middle of current and next card
    // even on devices without the bottom safe area.
    final bottomPadding = mQuery.padding.bottom;
    final extraBottomPadding =
        bottomPadding > 0 ? bottomPadding : kExtraBottomOffset;

    final defaultPadding = EdgeInsets.all(R.dimen.unit2);
    final navbarPadding = isKeyboardVisible
        ? defaultPadding
        : defaultPadding.copyWith(bottom: R.dimen.unit2 + extraBottomPadding);
    final stack = Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        buildNavigator(observers: [NavBarObserver()]),
        TooltipContextProvider(
          child: NavBar(
            padding: navbarPadding,
          ),
        ),
      ],
    );
    return InAppNotification(
      child: MaterialApp(
        theme: R.linden.themeData,
        home: NavBarContainer(
          child: ApplicationTooltipProvider(
            messageFactory: XaynMessageProvider.of(XaynMessageSet.values),
            child: stack,
          ),
        ),
      ),
    );
  }
}
