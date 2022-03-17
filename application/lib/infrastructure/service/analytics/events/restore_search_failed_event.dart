import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'restoreSearchFailed';

class RestoreSearchFailedEvent extends AnalyticsEvent {
  RestoreSearchFailedEvent({
    required RestoreSearchFailed event,
  }) : super(
          _kEventType,
          properties: event.toJson(),
        );
}
