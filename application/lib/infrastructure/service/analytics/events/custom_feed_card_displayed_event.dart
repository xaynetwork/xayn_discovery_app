import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'customFeedCardDisplayed';
const String _kParamCardType = 'cardType';

class CustomFeedCardDisplayedEvent extends AnalyticsEvent {
  CustomFeedCardDisplayedEvent({
    required CardType cardType,
  }) : super(
          _kEventType,
          properties: {
            _kParamCardType: cardType.name,
          },
        );
}
