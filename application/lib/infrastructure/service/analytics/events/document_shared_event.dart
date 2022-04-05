import 'package:xayn_discovery_app/domain/model/analytics/feed_analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentShared';
const String _kParamDocument = 'document';

/// An [FeedAnalyticsEvent] which tracks when a [Document] was shared.
/// - [document] is the target [Document].
class DocumentSharedEvent extends FeedAnalyticsEvent {
  DocumentSharedEvent({
    required Document document,
    required FeedType? feedType,
  }) : super(
          _kEventType,
          feedType: feedType,
          properties: {
            _kParamDocument: document.toJson(),
          },
        );
}
