import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'openExternalUrl';
const String _kParamUrl = 'url';
const String _kViewMode = 'currentView';

/// An [AnalyticsEvent] which tracks when an external url is opened
class OpenExternalUrlEvent extends AnalyticsEvent {
  OpenExternalUrlEvent({
    required String url,
    required CurrentView currentView,
  }) : super(
          _kEventType,
          properties: {
            _kParamUrl: url,
            _kViewMode: currentView.name,
          },
        );
}

enum CurrentView {
  story,
  reader,
  contact,
}
