import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const _kSessionStartEvent = 'Session start';

class AnalyticsEvents {
  AnalyticsEvents._();

  static const sessionStartEvent = AnalyticsEvent(_kSessionStartEvent);
}
