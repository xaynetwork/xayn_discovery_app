// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i6;
import 'package:flutter/material.dart' as _i7;

import '../../../../main.dart' as _i1;
import '../../../active_search/widget/active_search.dart' as _i4;
import '../../../discovery_feed/widget/discovery_feed.dart' as _i2;
import '../../../onboarding/widget/onboarding_screen.dart' as _i5;
import '../../../settings/settings_screen.dart' as _i3;

class AppRouter extends _i6.RootStackRouter {
  AppRouter([_i7.GlobalKey<_i7.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i6.PageFactory> pagesMap = {
    MainScreenRoute.name: (routeData) {
      return _i6.CupertinoPageX<dynamic>(
          routeData: routeData, child: const _i1.MainScreen());
    },
    DiscoveryFeedRoute.name: (routeData) {
      return _i6.CupertinoPageX<dynamic>(
          routeData: routeData, child: const _i2.DiscoveryFeed());
    },
    SettingsScreenRoute.name: (routeData) {
      final args = routeData.argsAs<SettingsScreenRouteArgs>();
      return _i6.CupertinoPageX<dynamic>(
          routeData: routeData,
          child: _i3.SettingsScreen(
              exampleParam: args.exampleParam, key: args.key));
    },
    ActiveSearchRoute.name: (routeData) {
      return _i6.CupertinoPageX<dynamic>(
          routeData: routeData, child: const _i4.ActiveSearch());
    },
    OnBoardingScreenRoute.name: (routeData) {
      return _i6.CustomPage<dynamic>(
          routeData: routeData,
          child: const _i5.OnBoardingScreen(),
          opaque: false,
          barrierDismissible: false);
    }
  };

  @override
  List<_i6.RouteConfig> get routes => [
        _i6.RouteConfig(MainScreenRoute.name, path: '/'),
        _i6.RouteConfig(DiscoveryFeedRoute.name, path: '/discovery-feed'),
        _i6.RouteConfig(SettingsScreenRoute.name, path: '/settings-screen'),
        _i6.RouteConfig(ActiveSearchRoute.name, path: '/active-search'),
        _i6.RouteConfig(OnBoardingScreenRoute.name, path: '/on-boarding-screen')
      ];
}

/// generated route for [_i1.MainScreen]
class MainScreenRoute extends _i6.PageRouteInfo<void> {
  const MainScreenRoute() : super(name, path: '/');

  static const String name = 'MainScreenRoute';
}

/// generated route for [_i2.DiscoveryFeed]
class DiscoveryFeedRoute extends _i6.PageRouteInfo<void> {
  const DiscoveryFeedRoute() : super(name, path: '/discovery-feed');

  static const String name = 'DiscoveryFeedRoute';
}

/// generated route for [_i3.SettingsScreen]
class SettingsScreenRoute extends _i6.PageRouteInfo<SettingsScreenRouteArgs> {
  SettingsScreenRoute({required bool exampleParam, _i7.Key? key})
      : super(name,
            path: '/settings-screen',
            args:
                SettingsScreenRouteArgs(exampleParam: exampleParam, key: key));

  static const String name = 'SettingsScreenRoute';
}

class SettingsScreenRouteArgs {
  const SettingsScreenRouteArgs({required this.exampleParam, this.key});

  final bool exampleParam;

  final _i7.Key? key;

  @override
  String toString() {
    return 'SettingsScreenRouteArgs{exampleParam: $exampleParam, key: $key}';
  }
}

/// generated route for [_i4.ActiveSearch]
class ActiveSearchRoute extends _i6.PageRouteInfo<void> {
  const ActiveSearchRoute() : super(name, path: '/active-search');

  static const String name = 'ActiveSearchRoute';
}

/// generated route for [_i5.OnBoardingScreen]
class OnBoardingScreenRoute extends _i6.PageRouteInfo<void> {
  const OnBoardingScreenRoute() : super(name, path: '/on-boarding-screen');

  static const String name = 'OnBoardingScreenRoute';
}
