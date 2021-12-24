import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/discovery_card_observation.dart';
import 'package:xayn_discovery_app/presentation/utils/enum_utils.dart';

const _kTimestampProperty = 'timestamp';
const _kViewTypeProperty = 'viewType';

class SwipeCardAnalyticsEvent extends _DiscoveryCardAnalyticsEvent {
  SwipeCardAnalyticsEvent(TimestampedDiscoveryCardObservation card)
      : super(card);

  @override
  String get name => 'Swipe Discovery Card';
}

class ChangeCardViewTypeAnalyticsEvent extends _DiscoveryCardAnalyticsEvent {
  ChangeCardViewTypeAnalyticsEvent(TimestampedDiscoveryCardObservation card)
      : super(card);

  @override
  String get name => 'Open Discovery Card in $viewType';
}

class _DiscoveryCardAnalyticsEvent implements AnalyticsEvent {
  _DiscoveryCardAnalyticsEvent(this.card);

  final TimestampedDiscoveryCardObservation card;

  String? get viewType => card.value.viewType != null
      ? enumToSpacedString(card.value.viewType!)
      : null;

  @override
  String get name => throw UnimplementedError();

  @override
  Map<String, dynamic>? get properties {
    final propertiesMap = <String, dynamic>{
      _kTimestampProperty: card.timestamp.toIso8601String(),
      _kViewTypeProperty: viewType,
    };

    if (card.value.document != null) {
      propertiesMap.addAll(card.value.document!.toJson());
    }

    return propertiesMap;
  }
}
