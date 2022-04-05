import 'package:xayn_discovery_app/domain/model/analytics/feed_analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentIndexChanged';
const String _kParamNextDocument = 'nextDocument';
const String _kParamDirection = 'direction';

enum Direction { start, up, down }

/// An [FeedAnalyticsEvent] which tracks when a user vertically swipes in the feed.
/// - [next] is the document which will be the next main card in view
/// - [direction] indicates the vertical swipe direction, up or down.
/// - [feedType] indicates the current screen the event was triggered from.
class DocumentIndexChangedEvent extends FeedAnalyticsEvent {
  DocumentIndexChangedEvent({
    required Document next,
    required Direction direction,
    required FeedType feedType,
  }) : super(
          _kEventType,
          feedType: feedType,
          properties: {
            _kParamNextDocument: next.toJson(),
            _kParamDirection: direction.name,
          },
        );
}
