import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'openSubscriptionWindow';
const String _kParamCurrentView = 'currentView';
const String _kParamArguments = 'arguments';

/// An [AnalyticsEvent] which tracks when subsciption window is open.
/// - [currentView] is the name of the screen that was navigated from.
/// - [arguments] are optional screen parameters.
class OpenSubscriptionWindowEvent extends AnalyticsEvent {
  OpenSubscriptionWindowEvent({
    required SubscriptionWindowCurrentView currentView,
    Object? arguments,
  }) : super(
          _kEventType,
          properties: {
            _kParamCurrentView: currentView.name,
            if (arguments != null) _kParamArguments: arguments,
          },
        );
}

enum SubscriptionWindowCurrentView {
  personalArea,
  settings,
  feed,
}
