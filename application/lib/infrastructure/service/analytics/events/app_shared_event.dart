import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'appShared';

class AppSharedEvent extends AnalyticsEvent {
  AppSharedEvent() : super(_kEventType);
}
