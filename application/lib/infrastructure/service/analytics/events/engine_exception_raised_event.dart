import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'engineExceptionRaised';
const String _kParamReason = 'reason';
const String _kParamMessage = 'message';
const String _kParamStackTrace = 'stackTrace';

/// An [AnalyticsEvent] which tracks when an engine exception occurred.
/// - [event] is matching error event from the engine.
class EngineExceptionRaisedEvent extends AnalyticsEvent {
  EngineExceptionRaisedEvent({
    required EngineExceptionRaised event,
  }) : super(
          _kEventType,
          properties: {
            _kParamReason: event.reason.name,
            if (event.message != null) _kParamMessage: event.message!,
            if (event.stackTrace != null) _kParamStackTrace: event.stackTrace!,
          },
        );
}
