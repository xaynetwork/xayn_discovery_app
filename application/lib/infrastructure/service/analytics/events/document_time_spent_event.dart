import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'documentTimeSpent';
const String _kParamDurationInSeconds = 'duration';
const String _kParamViewMode = 'viewMode';
const String _kParamDocument = 'document';

/// An [AnalyticsEvent] which tracks time spent in a card view mode (reader, or story).
/// - [document] is the target [Document].
/// - [viewMode] indicates if the card was viewed in story or reader mode
/// - [duration] indicates the amount of time spent
class DocumentTimeSpentEvent extends AnalyticsEvent {
  DocumentTimeSpentEvent({
    required Document document,
    required Duration duration,
    required DocumentViewMode viewMode,
  }) : super(
          _kEventType,
          properties: {
            _kParamDurationInSeconds: duration.inSeconds,
            _kParamViewMode: viewMode.name,
            _kParamDocument: document.toJson(),
          },
        );
}
