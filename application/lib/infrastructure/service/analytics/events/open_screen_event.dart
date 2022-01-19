import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/presentation/utils/string_utils.dart';

const String _kEventType = 'openScreen';
const String _kParamScreen = 'screen';
const String _kParamArguments = 'arguments';

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
