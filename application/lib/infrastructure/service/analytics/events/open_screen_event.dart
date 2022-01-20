import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/presentation/utils/string_utils.dart';

const String _kEventType = 'openScreen';
const String _kParamScreen = 'screen';
const String _kParamArguments = 'arguments';

/// An [AnalyticsEvent] which tracks when switching screens.
/// - [screenName] is the name of the screen that was navigated into.
/// - [arguments] are optional screen parameters.
class OpenScreenEvent extends AnalyticsEvent {
  OpenScreenEvent({
    required String screenName,
    Object? arguments,
  }) : super(
          _kEventType,
          properties: {
            _kParamScreen: screenName.capitalize(allWords: true),
            if (arguments != null) _kParamArguments: arguments,
          },
        );
}
