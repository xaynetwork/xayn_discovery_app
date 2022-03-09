import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'engineInitFailed';
const String _kParamError = 'error';

/// An [AnalyticsEvent] which tracks when an engine init exception occurred.
/// - [error] is matching error event from the engine init.
/// - [stackTrace] is matching stackTrace.
class EngineInitFailedEvent extends AnalyticsEvent {
  EngineInitFailedEvent({
    required Object error,
  }) : super(
          _kEventType,
          properties: {
            _kParamError: error,
          },
        );
}
