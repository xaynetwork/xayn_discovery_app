import 'package:xayn_discovery_app/domain/model/analytics/feed_analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentBookmarked';
const String _kParamDocument = 'document';
const String _kParamIsBookmarked = 'isBookmarked';
const String _kParamToDefaultCollection = 'toDefaultCollection';

/// An [FeedAnalyticsEvent] which tracks when a [Document] was bookmarked, or not.
/// - [document] is the target [Document].
/// - [isBookmarked] is true when bookmarked, false when not.
/// - [feedType] indicates the current screen the event was triggered from.
class DocumentBookmarkedEvent extends FeedAnalyticsEvent {
  DocumentBookmarkedEvent({
    Document? previous,
    required Document document,
    required bool isBookmarked,
    required bool toDefaultCollection,
    FeedType? feedType,
  }) : super(
          _kEventType,
          feedType: feedType,
          properties: {
            _kParamDocument: document.toJson(),
            _kParamIsBookmarked: isBookmarked,
            _kParamToDefaultCollection: toDefaultCollection,
          },
        );
}
