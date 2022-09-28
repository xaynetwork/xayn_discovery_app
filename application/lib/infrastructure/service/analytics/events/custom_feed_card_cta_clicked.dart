import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const String _kEventType = 'customFeedCardCTAClicked';
const String _kParamCardType = 'cardType';

class CustomFeedCardCTAClickedEvent extends AnalyticsEvent {
  CustomFeedCardCTAClickedEvent({
    required CardType cardType,
  }) : super(
          _kEventType,
          properties: {
            _kParamCardType: cardType.name,
          },
        );
}
