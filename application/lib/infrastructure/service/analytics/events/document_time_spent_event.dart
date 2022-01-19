import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentTimeSpent';
const String _kParamDocumentId = 'documentId';
const String _kParamDurationInSeconds = 'duration';
const String _kParamViewMode = 'viewMode';

class DocumentTimeSpentEvent extends AnalyticsEvent {
  DocumentTimeSpentEvent({
    required Document document,
    required Duration duration,
    required DocumentViewMode viewMode,
  }) : super(
          _kEventType,
          properties: {
            _kParamDocumentId: document.documentId,
            _kParamDurationInSeconds: duration.inSeconds,
            _kParamViewMode: viewMode.stringify(),
          },
        );
}
