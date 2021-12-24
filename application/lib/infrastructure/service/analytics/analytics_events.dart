import 'package:flutter/widgets.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const _kArgumentsProperty = 'arguments';

class AnalyticsEvents {
  AnalyticsEvents._();

  static String _openScreenEvent(String routeName) => 'Open $routeName screen';

  static AnalyticsEvent openScreenEvent(Route route) => AnalyticsEvent(
        _openScreenEvent(route.settings.name!),
        properties: route.settings.arguments == null
            ? {}
            : {_kArgumentsProperty: route.settings.arguments},
      );
}
