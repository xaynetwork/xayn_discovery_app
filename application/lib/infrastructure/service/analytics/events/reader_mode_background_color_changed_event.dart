import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';

const String _kEventType = 'readerModeBackgroundColorChanged';
const String _kParamLightBackgroundColor = 'lightBackgroundColor';
const String _kParamDarkBackgroundColor = 'darkBackgroundColor';

class ReaderModeBackgroundColorChanged extends AnalyticsEvent {
  ReaderModeBackgroundColorChanged({
    required ReaderModeBackgroundColor backgroundColor,
  }) : super(
          _kEventType,
          properties: {
            _kParamLightBackgroundColor: backgroundColor.light.name,
            _kParamDarkBackgroundColor: backgroundColor.dark.name,
          },
        );
}
