import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'af_bookmark';

class BookmarkMarketingEvent extends AnalyticsEvent {
  BookmarkMarketingEvent() : super(_kEventType);
}
