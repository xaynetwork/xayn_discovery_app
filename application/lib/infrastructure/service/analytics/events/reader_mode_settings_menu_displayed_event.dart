import 'package:xayn_discovery_app/domain/model/analytics/feed_analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';

const String _kEventType = 'readerModeSettingsMenuDisplayed';
const String _kParamIsVisible = 'isVisible';

/// An [FeedAnalyticsEvent] which tracks when a menu is displayed/hidden in reader mode.
/// - [isVisible] indicates whether the menu is visible.
/// - [feedType] indicates the current screen the event was triggered from.
class ReaderModeSettingsMenuDisplayedEvent extends FeedAnalyticsEvent {
  ReaderModeSettingsMenuDisplayedEvent({
    required bool isVisible,
    required FeedType feedType,
  }) : super(
          _kEventType,
          feedType: feedType,
          properties: {
            _kParamIsVisible: isVisible,
          },
        );
}
