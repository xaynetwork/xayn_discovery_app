import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentIndexChanged';
const String _kParamPreviousDocumentId = 'previousDocumentId';
const String _kParamNextDocumentId = 'nextDocumentId';
const String _kParamDirection = 'direction';

enum Direction { up, down }

class DocumentChangedEvent extends AnalyticsEvent {
  DocumentChangedEvent({
    required Document previous,
    required Document next,
    required Direction direction,
  }) : super(
          _kEventType,
          properties: {
            _kParamPreviousDocumentId: previous.documentId,
            _kParamNextDocumentId: next.documentId,
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
    }
  }
}
