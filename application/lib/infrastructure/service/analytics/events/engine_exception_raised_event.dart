import 'package:xayn_discovery_app/domain/model/analytics/feed_analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'engineExceptionRaised';
const String _kParamReason = 'reason';
const String _kParamMessage = 'message';
const String _kParamStackTrace = 'stackTrace';

/// An [FeedAnalyticsEvent] which tracks when an engine exception occurred.
/// - [event] is matching error event from the engine.
/// - [feedType] indicates the current screen the event was triggered from.
class EngineExceptionRaisedEvent extends FeedAnalyticsEvent {
  EngineExceptionRaisedEvent({
    required EngineExceptionRaised event,
    required FeedType feedType,
  }) : super(
          _kEventType,
          feedType: feedType,
          properties: {
            _kParamReason: event.reason.name,
            if (event.message != null) _kParamMessage: event.message!,
            if (event.stackTrace != null) _kParamStackTrace: event.stackTrace!,
          },
        );
}
