import 'package:xayn_discovery_app/domain/model/analytics/feed_analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';

const String _kEventType = 'openExternalUrl';
const String _kParamUrl = 'url';
const String _kViewMode = 'currentView';

/// An [FeedAnalyticsEvent] which tracks when an external url is opened
class OpenExternalUrlEvent extends FeedAnalyticsEvent {
  OpenExternalUrlEvent({
    required String url,
    required CurrentView currentView,
    FeedType? feedType,
  }) : super(
          _kEventType,
          feedType: feedType,
          properties: {
            _kParamUrl: url,
            _kViewMode: currentView.name,
          },
        );
}

enum CurrentView {
  story,
  reader,
  settings,
}
