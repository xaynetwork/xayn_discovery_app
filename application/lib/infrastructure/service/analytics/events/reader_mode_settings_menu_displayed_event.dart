import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';

const String _kEventType = 'readerModeSettingsMenuDisplayed';
const String _kParamIsVisible = 'isVisible';
const String _kParamFeedType = 'feedType';

/// An [AnalyticsEvent] which tracks when a menu is displayed/hidden in reader mode.
/// - [isVisible] indicates whether the menu is visible.
/// - [feedType] indicates the current screen the event was triggered from.
class ReaderModeSettingsMenuDisplayedEvent extends AnalyticsEvent {
  ReaderModeSettingsMenuDisplayedEvent({
    required bool isVisible,
    required FeedType feedType,
  }) : super(
          _kEventType,
          properties: {
            _kParamIsVisible: isVisible,
            _kParamFeedType: feedType.name,
          },
        );
}
