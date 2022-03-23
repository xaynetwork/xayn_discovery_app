import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';

const String _kEventType = 'readerModeFontSizeChanged';
const String _kParamFontSize = 'fontSize';

class ReaderModeFontSizeChanged extends AnalyticsEvent {
  ReaderModeFontSizeChanged({
    required ReaderModeFontSize fontSize,
  }) : super(
          _kEventType,
          properties: {
            _kParamFontSize: fontSize.name,
          },
        );
}
