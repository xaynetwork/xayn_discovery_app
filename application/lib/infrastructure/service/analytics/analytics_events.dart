import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';

const _kClickedCardEvent = 'Clicked a card';

class AnalyticsEvents {
  AnalyticsEvents._();

  static const clickedCardEvent = AnalyticsEvent(_kClickedCardEvent);
}
