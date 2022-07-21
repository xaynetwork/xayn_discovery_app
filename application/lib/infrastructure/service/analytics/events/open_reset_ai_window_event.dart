import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'resetAIWindow';

class OpenResetAIWindowEvent extends AnalyticsEvent {
  OpenResetAIWindowEvent()
      : super(
          _kEventType,
        );
}
