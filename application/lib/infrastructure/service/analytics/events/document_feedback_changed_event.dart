import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentFeedbackChanged';
const String _kParamDocument = 'document';
const String _kParamContext = 'context';

/// An [AnalyticsEvent] which tracks when a [Document]'s feedback was changed'.
/// - [document] is the target [Document].
///
/// The document must already have [Document.feedback] updated, as the full
/// document will be logged in the event.
class DocumentFeedbackChangedEvent extends AnalyticsEvent {
  DocumentFeedbackChangedEvent({
    required Document document,
    required FeedbackContext context,
  }) : super(
          _kEventType,
          properties: {
            _kParamDocument: document.toJson(),
            _kParamContext: context.name,
          },
        );
}
