import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';

const String _kParamFeedType = 'feedType';

abstract class FeedAnalyticsEvent extends AnalyticsEvent {
  FeedAnalyticsEvent(
    String type, {
    required FeedType? feedType,
    Map<String, dynamic>? properties,
  }) : super(
          type,
          properties: {
            if (feedType != null) _kParamFeedType: feedType.name,
          }..addAll(properties ?? {}),
        );
}
