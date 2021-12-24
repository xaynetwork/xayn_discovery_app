import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_screen_analytics_event.dart';

/// Listen to navigation changes and log [AnalyticsEvents].
@lazySingleton
class LogOpenRouteAnalyticsUseCase extends UseCase<Route, Route> {
  final AnalyticsService _analyticsService;

  LogOpenRouteAnalyticsUseCase(this._analyticsService);

  @override
  Stream<Route> transaction(Route param) {
    final event = OpenScreenAnalyticsEvent(param);
    _analyticsService.logEvent(event);
    return Stream.value(param);
  }

  @override
  Stream<Route> transform(Stream<Route> incoming) => incoming.distinct();
}
