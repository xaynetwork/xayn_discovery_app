import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'feedbackGiven';

class FeedbackGivenEvent extends AnalyticsEvent {
  FeedbackGivenEvent() : super(_kEventType);
}
