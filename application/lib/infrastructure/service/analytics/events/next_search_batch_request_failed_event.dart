import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const String _kEventType = 'nextSearchBatchRequestFailed';

class NextSearchBatchRequestFailedEvent extends AnalyticsEvent {
  NextSearchBatchRequestFailedEvent({
    required NextSearchBatchRequestFailed event,
  }) : super(
          _kEventType,
          properties: event.toJson(),
        );
}
