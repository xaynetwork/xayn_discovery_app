import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'screenTimeSpent';
const String _kParamScreen = 'screen';
const String _kParamArguments = 'arguments';
const String _kParamDuration = 'duration';

/// An [AnalyticsEvent] which tracks the duration of a screen
/// - [screenName] is the name of the screen that was navigated into.
/// - [arguments] are optional screen parameters.
/// - [duration] is the time in seconds when the screen was open
class ScreenTimeSpentEvent extends AnalyticsEvent {
  ScreenTimeSpentEvent({
    required String screenName,
    required Duration duration,
    Object? arguments,
  }) : super(
          _kEventType,
          properties: {
            _kParamScreen: screenName,
            if (arguments != null) _kParamArguments: arguments,
            _kParamDuration: duration.inSeconds,
          },
        );
}
