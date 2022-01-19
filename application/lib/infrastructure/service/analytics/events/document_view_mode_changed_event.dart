import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentViewModeChanged';
const String _kParamViewMode = 'viewMode';
const String _kParamDocument = 'document';

class DocumentViewModeChangedEvent extends AnalyticsEvent {
  DocumentViewModeChangedEvent({
    required Document document,
    required DocumentViewMode viewMode,
  }) : super(
          _kEventType,
          properties: {
            _kParamViewMode: viewMode.stringify(),
            _kParamDocument: document,
          },
        );
}
