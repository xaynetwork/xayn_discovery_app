import 'package:flutter/material.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';

class AppRouter extends xayn.NavigatorDelegate {
  AppRouter(AppNavigationManager navigationManager) : super(navigationManager);

  @override
  Widget build(BuildContext context) {
    final navigator = buildNavigator(
      observers: [NavBarObserver()],
    );

    return MaterialApp(
      theme: R.linden.themeData,
      home: NavBarContainer(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            navigator,
            const NavBar(),
          ],
        ),
      ),
    );
  }
}
