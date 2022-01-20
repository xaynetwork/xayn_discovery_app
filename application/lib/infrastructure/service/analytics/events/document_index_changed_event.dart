import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentIndexChanged';
const String _kParamPreviousDocument = 'previousDocument';
const String _kParamNextDocument = 'nextDocument';
const String _kParamDirection = 'direction';

enum Direction { start, up, down }

class DocumentIndexChangedEvent extends AnalyticsEvent {
  DocumentIndexChangedEvent({
    Document? previous,
    required Document next,
    required Direction direction,
  }) : super(
          _kEventType,
          properties: {
            if (previous != null) _kParamPreviousDocument: previous,
            _kParamNextDocument: next,
            _kParamDirection: direction.stringify(),
          },
        );
}

extension DirectionExtension on Direction {
  String stringify() {
    switch (this) {
      case Direction.down:
        return 'down';
      case Direction.up:
        return 'up';
      case Direction.start:
        return 'start';
    }
  }
}
