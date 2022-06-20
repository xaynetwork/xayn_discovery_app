import 'package:xayn_discovery_app/domain/model/analytics/feed_analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';

const String _kEventType = 'openExternalUrl';
const String _kParamUrl = 'url';
const String _kViewMode = 'currentView';

/// An [FeedAnalyticsEvent] which tracks when an external url is opened
class OpenExternalUrlEvent extends FeedAnalyticsEvent {
  final String url;
  final CurrentView currentView;
  final FeedType? feedType;

  OpenExternalUrlEvent({
    required this.url,
    required this.currentView,
    this.feedType,
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
  search,
  reader,
  settings,
  bookmark,
  personalArea,
}
