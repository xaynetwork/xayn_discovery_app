import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'bugReported';

class BugReportedEvent extends AnalyticsEvent {
  BugReportedEvent() : super(_kEventType);
}
