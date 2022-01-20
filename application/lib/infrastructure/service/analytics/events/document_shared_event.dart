import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentShared';
const String _kParamDocument = 'document';

class DocumentSharedEvent extends AnalyticsEvent {
  DocumentSharedEvent({
    Document? previous,
    required Document document,
  }) : super(
          _kEventType,
          properties: {
            _kParamDocument: document,
          },
        );
}
