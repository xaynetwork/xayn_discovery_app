import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'subscriptionAction';
const String _kParamAction = 'action';
const String _kParamArguments = 'arguments';

/// An [AnalyticsEvent] which tracks when user taps on a button or link
/// on the subscription window.
/// - [action] is the name of the action performed by the user.
/// - [arguments] are optional action parameters.
class SubscriptionActionEvent extends AnalyticsEvent {
  SubscriptionActionEvent({
    required SubscriptionAction action,
    Object? arguments,
  }) : super(
          _kEventType,
          properties: {
            _kParamAction: action.name,
            if (arguments != null) _kParamArguments: arguments,
          },
        );
}

enum SubscriptionAction {
  subscribe,
  unsubscribe,
  cancel,
  restore,
  promoCode,
}
