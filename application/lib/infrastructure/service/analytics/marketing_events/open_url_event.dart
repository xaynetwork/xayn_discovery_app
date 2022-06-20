import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'af_openUrl';

class OpenUrlMarketingEvent extends AnalyticsEvent {
  OpenUrlMarketingEvent() : super(_kEventType);
}
