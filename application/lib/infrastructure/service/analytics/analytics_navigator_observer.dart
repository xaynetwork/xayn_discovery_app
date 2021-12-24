import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_events.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

class AnalyticsNavigatorObserver extends NavigatorObserver {
  late final AnalyticsService _analyticsService;

  AnalyticsNavigatorObserver(this._analyticsService);

  void _observeNewRoute(Route route) {
    if (route.settings.name == null) {
      logger.e(
        'A route with `name = null` has been tracked by analytics navigator observer',
      );
      return;
    }
    final event = AnalyticsEvents.openScreenEvent(route);
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
