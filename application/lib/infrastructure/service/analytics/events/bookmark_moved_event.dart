import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'bookmarkMoved';
const String _kParamToDefaultCollection = 'toDefaultCollection';

class BookmarkMovedEvent extends AnalyticsEvent {
  BookmarkMovedEvent({
    required bool toDefaultCollection,
  }) : super(
          _kEventType,
          properties: {
            _kParamToDefaultCollection: toDefaultCollection,
          },
        );
}
