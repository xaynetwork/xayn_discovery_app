import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/log_open_route_analytics_use_case.dart';

class AnalyticsNavigatorObserver extends NavigatorObserver {
  late final LogOpenRouteAnalyticsUseCase _logOpenRouteUseCase;

  AnalyticsNavigatorObserver() {
    _logOpenRouteUseCase = di.get();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _logOpenRouteUseCase.call(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) _logOpenRouteUseCase.call(newRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (previousRoute != null) _logOpenRouteUseCase.call(previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) _logOpenRouteUseCase.call(previousRoute);
  }
}
