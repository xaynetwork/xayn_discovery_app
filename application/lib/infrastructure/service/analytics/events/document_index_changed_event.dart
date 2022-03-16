import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentIndexChanged';
const String _kParamNextDocument = 'nextDocument';
const String _kParamDirection = 'direction';

enum Direction { start, up, down }

/// An [AnalyticsEvent] which tracks when a user vertically swipes in the feed.
/// - [next] is the document which will be the next main card in view
/// - [direction] indicates the vertical swipe direction, up or down.
class DocumentIndexChangedEvent extends AnalyticsEvent {
  DocumentIndexChangedEvent({
    required Document next,
    required Direction direction,
  }) : super(
          _kEventType,
          properties: {
            _kParamNextDocument: next.toJson(),
            _kParamDirection: direction.name,
          },
        );
}
