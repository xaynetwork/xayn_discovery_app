import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentIndexChanged';
const String _kParamPreviousDocument = 'previousDocument';
const String _kParamNextDocument = 'nextDocument';
const String _kParamDirection = 'direction';

enum Direction { start, up, down }

/// An [AnalyticsEvent] which tracks when a user vertically swipes in the feed.
/// - [previous] is the document that was swiped away. It can be null, if no swipe took place before.
/// - [next] is the document which will be the next main card in view
/// - [direction] indicates the vertical swipe direction, up or down.
class DocumentIndexChangedEvent extends AnalyticsEvent {
  DocumentIndexChangedEvent({
    Document? previous,
    required Document next,
    required Direction direction,
  }) : super(
          _kEventType,
          properties: {
            if (previous != null) _kParamPreviousDocument: previous.toJson(),
            _kParamNextDocument: next.toJson(),
            _kParamDirection: direction.name,
          },
        );
}
