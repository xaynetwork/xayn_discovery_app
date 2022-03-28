import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'openSubscriptionWindow';
const String _kParamCurrentView = 'currentView';
const String _kParamDurationInSeconds = 'duration';

/// An [AnalyticsEvent] which tracks when subsciption window is open.
/// - [currentView] is the name of the screen that was navigated from.
/// - [duration] indicates the amount of time spent
class OpenSubscriptionWindowEvent extends AnalyticsEvent {
  OpenSubscriptionWindowEvent({
    required SubscriptionWindowCurrentView currentView,
    required Duration duration,
  }) : super(
          _kEventType,
          properties: {
            _kParamCurrentView: currentView.name,
            _kParamDurationInSeconds: duration.inSeconds,
          },
        );
}

enum SubscriptionWindowCurrentView {
  personalArea,
  settings,
  feed,
}
