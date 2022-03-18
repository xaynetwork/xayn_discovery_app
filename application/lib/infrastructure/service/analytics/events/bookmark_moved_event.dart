import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'bookmarkMoved';

class BookmarkMovedEvent extends AnalyticsEvent {
  BookmarkMovedEvent() : super(_kEventType);
}
