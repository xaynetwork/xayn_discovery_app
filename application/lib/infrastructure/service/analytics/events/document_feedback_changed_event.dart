import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentFeedbackChanged';
const String _kParamDocument = 'document';

class DocumentFeedbackChangedEvent extends AnalyticsEvent {
  DocumentFeedbackChangedEvent({
    required Document document,
  }) : super(
          _kEventType,
          properties: {_kParamDocument: document},
        );
}
