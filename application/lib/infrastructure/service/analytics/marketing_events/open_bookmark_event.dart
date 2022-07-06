import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'af_openBookmark';

class OpenBookmarkMarketingEvent extends AnalyticsEvent {
  OpenBookmarkMarketingEvent() : super(_kEventType);
}
