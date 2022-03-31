import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'bookmarkDeleted';
const String _kParamFromDefaultCollection = 'fromDefaultCollection';

class BookmarkDeletedEvent extends AnalyticsEvent {
  BookmarkDeletedEvent({
    required bool fromDefaultCollection,
  }) : super(
          _kEventType,
          properties: {
            _kParamFromDefaultCollection: fromDefaultCollection,
          },
        );
}
