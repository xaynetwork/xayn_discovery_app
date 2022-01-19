import 'package:flutter/material.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_design/xayn_design.dart' hide NavBarObserver;
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/navigation/observer/nav_bar_observer.dart';
import 'package:xayn_discovery_app/presentation/widget/tooltip/messages.dart';

class AppRouter extends xayn.NavigatorDelegate {
  AppRouter(AppNavigationManager navigationManager) : super(navigationManager);

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        buildNavigator(observers: [NavBarObserver()]),
        const TooltipContextProvider(child: NavBar()),
      ],
    );
    return MaterialApp(
      theme: R.linden.themeData,
      home: NavBarContainer(
        child: ApplicationTooltipProvider(
          messageFactory: XaynMessageProvider.of(XaynMessageSet.values),
          child: stack,
        ),
      ),
    );
  }
}
