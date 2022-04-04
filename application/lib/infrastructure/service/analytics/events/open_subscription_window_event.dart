import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'openSubscriptionWindow';
const String _kParamCurrentView = 'currentView';
const String _kParamDurationInSeconds = 'duration';
const String _kParamDaysToSubscribe = 'daysToSubscribe';
const String _kParamSubscriptionDate = 'subscriptionDate';

/// An [AnalyticsEvent] which tracks when subsciption window is open.
/// - [currentView] is the name of the screen that was navigated from.
/// - [duration] indicates the amount of time spent
/// - [daysToSubscribe] indicates how many days left until free trial expires
/// - [subscriptionDate] indicates when the user purchased the subscription
class OpenSubscriptionWindowEvent extends AnalyticsEvent {
  OpenSubscriptionWindowEvent({
    required SubscriptionWindowCurrentView currentView,
    required Duration duration,
    required int? daysToSubscribe,
    required DateTime? subscriptionDate,
  }) : super(
          _kEventType,
          properties: {
            _kParamCurrentView: currentView.name,
            _kParamDurationInSeconds: duration.inSeconds,
            if (daysToSubscribe != null)
              _kParamDaysToSubscribe: daysToSubscribe,
            if (subscriptionDate != null)
              _kParamSubscriptionDate: subscriptionDate,
          },
        );
}

enum SubscriptionWindowCurrentView {
  personalArea,
  settings,
  feed,
}
