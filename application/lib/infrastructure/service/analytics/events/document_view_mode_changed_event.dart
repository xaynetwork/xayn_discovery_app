import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentViewModeChanged';
const String _kParamDocumentId = 'documentId';
const String _kParamViewMode = 'viewMode';

enum Direction { up, down }

class DocumentChangedEvent extends AnalyticsEvent {
  DocumentChangedEvent({
    required Document document,
    required DocumentViewMode viewMode,
  }) : super(
          _kEventType,
          properties: {
            _kParamDocumentId: document.documentId,
            _kParamViewMode: viewMode.stringify(),
          },
        );
}
