import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';

const String _kEventType = 'readerModeFontStyleChanged';
const String _kParamFontStyle = 'fontStyle';

class ReaderModeFontStyleChanged extends AnalyticsEvent {
  ReaderModeFontStyleChanged({
    required ReaderModeFontStyle fontStyle,
  }) : super(
          _kEventType,
          properties: {
            _kParamFontStyle: fontStyle.name,
          },
        );
}
