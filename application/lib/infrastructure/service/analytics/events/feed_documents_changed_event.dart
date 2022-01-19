import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'feedDocumentsChanged';
const String _kParamDocuments = 'documents';

class FeedDocumentsChangedEvent extends AnalyticsEvent {
  FeedDocumentsChangedEvent({
    required Set<Document> documents,
  }) : super(
          _kEventType,
          properties: {
            _kParamDocuments: documents,
          },
        );
}
