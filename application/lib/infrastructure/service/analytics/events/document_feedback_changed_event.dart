import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentFeedbackChanged';
const String _kParamDocument = 'document';

/// An [AnalyticsEvent] which tracks when a [Document]'s feedback was changed'.
/// - [document] is the target [Document].
///
/// The document must already have [Document.feedback] updated, as the full
/// document will be logged in the event.
class DocumentFeedbackChangedEvent extends AnalyticsEvent {
  DocumentFeedbackChangedEvent({
    required Document document,
  }) : super(
          _kEventType,
          properties: {_kParamDocument: document},
        );
}
