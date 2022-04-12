import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:xayn_architecture/xayn_architecture_navigation.dart' as xayn;
import 'package:xayn_design/xayn_design.dart' hide NavBarObserver;
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/navigation/app_navigator.dart';
import 'package:xayn_discovery_app/presentation/navigation/observer/nav_bar_observer.dart';
import 'package:xayn_discovery_app/presentation/widget/connection_snackbar/connection_snackbar.dart';
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
    final topPadding = mQuery.padding.top;
    final extraBottomPadding =
        bottomPadding > 0 ? bottomPadding : kExtraBottomOffset;

    final defaultPadding = EdgeInsets.symmetric(
      vertical: R.dimen.unit2,
      horizontal: R.dimen.unit4,
    );
    final navbarPadding = isKeyboardVisible
        ? defaultPadding
        : defaultPadding.copyWith(bottom: R.dimen.unit2 + extraBottomPadding);

    final ConnectivityObserver connectivityObserver = di.get();
    final stack = Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        _buildScaffold(connectivityObserver),
        TooltipContextProvider(
          child: NavBar(
            padding: navbarPadding,
          ),
        ),
        Positioned(
          top: topPadding,
          right: 0.0,
          left: 0.0,
          child: _buildSnackBarConnection(
            connectivityObserver,
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

  Widget _buildScaffold(ConnectivityObserver connectivityObserver) => Scaffold(
        body: StreamBuilder<Object>(
          stream: connectivityObserver.onConnectivityChanged,
          builder: (context, snapshot) =>
              snapshot.data == ConnectivityResult.none
                  ? _buildNavigatorWithPadding()
                  : buildNavigator(
                      observers: [NavBarObserver()],
                    ),
        ),
      );

  Widget _buildSnackBarConnection(ConnectivityObserver connectivityObserver) =>
      StreamBuilder<Object>(
        stream: connectivityObserver.onConnectivityChanged,
        builder: (_, snapshot) => snapshot.data == ConnectivityResult.none
            ? ConnectionSnackBar()
            : Container(),
      );

  Widget _buildNavigatorWithPadding() => Padding(
        padding: EdgeInsets.only(top: R.dimen.connectionErrorWidgetHeight),
        child: buildNavigator(
          observers: [NavBarObserver()],
        ),
      );
}
