import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size_param.dart';

const String _kEventType = 'readerModeFontSizeChanged';
const String _kParamFontSize = 'fontSize';

class ReaderModeFontSizeParamChanged extends AnalyticsEvent {
  ReaderModeFontSizeParamChanged({
    required ReaderModeFontSizeParam fontSizeParam,
  }) : super(
          _kEventType,
          properties: {
            _kParamFontSize: 'size_${fontSizeParam.size}',
          },
        );
}
