import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_screen_analytics_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';

class AnalyticsNavigatorObserver extends NavigatorObserver {
  late final AnalyticsService _analyticsService;

  AnalyticsNavigatorObserver(this._analyticsService);

  void _observeNewRoute(Route route) {
    final event = OpenScreenAnalyticsEvent(route);
    _analyticsService.logEvent(event);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _observeNewRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) _observeNewRoute(newRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    if (previousRoute != null) _observeNewRoute(previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) _observeNewRoute(previousRoute);
  }
}
