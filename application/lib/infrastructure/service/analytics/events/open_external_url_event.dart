import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'openExternalUrl';
const String _kParamUrl = 'url';

/// An [AnalyticsEvent] which tracks when an external url is opened
class OpenExternalUrlEvent extends AnalyticsEvent {
  OpenExternalUrlEvent({
    required String url,
  }) : super(
          _kEventType,
          properties: {
            _kParamUrl: url,
          },
        );
}
