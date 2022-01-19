import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentFeedbackChanged';
const String _kParamDocumentId = 'documentId';
const String _kParamFeedback = 'feedback';

class DocumentFeedbackEvent extends AnalyticsEvent {
  DocumentFeedbackEvent({
    required Document document,
    required DocumentFeedback feedback,
  }) : super(
          _kEventType,
          properties: {
            _kParamDocumentId: document.documentId,
            _kParamFeedback: feedback.stringify(),
          },
        );
}
