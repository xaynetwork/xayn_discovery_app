import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'readerModeSettingsMenuDisplayed';
const String _kParamIsVisible = 'isVisible';

class ReaderModeSettingsMenuDisplayedEvent extends AnalyticsEvent {
  ReaderModeSettingsMenuDisplayedEvent({
    required bool isVisible,
  }) : super(
          _kEventType,
          properties: {
            _kParamIsVisible: isVisible,
          },
        );
}
