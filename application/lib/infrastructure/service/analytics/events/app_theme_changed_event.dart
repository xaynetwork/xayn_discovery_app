import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';

const String _kEventType = 'appThemeChanged';
const String _kParamTheme = 'theme';

class AppThemeChangedEvent extends AnalyticsEvent {
  AppThemeChangedEvent({
    required AppTheme theme,
  }) : super(
          _kEventType,
          properties: {
            _kParamTheme: theme.name,
          },
        );
}
