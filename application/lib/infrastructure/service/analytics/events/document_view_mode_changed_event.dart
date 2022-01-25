import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentViewModeChanged';
const String _kParamViewMode = 'viewMode';
const String _kParamDocument = 'document';

/// An [AnalyticsEvent] which tracks when a card switches view mode between story and reader.
/// - [document] is the target [Document].
/// - [viewMode] indicates the mode, story or reader.
class DocumentViewModeChangedEvent extends AnalyticsEvent {
  DocumentViewModeChangedEvent({
    required Document document,
    required DocumentViewMode viewMode,
  }) : super(
          _kEventType,
          properties: {
            _kParamViewMode: viewMode.name,
            _kParamDocument: document,
          },
        );
}
