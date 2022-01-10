import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/analytics_service.dart';
import 'package:xayn_discovery_app/domain/model/discovery_card_observation.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/discovery_card_analytics_event.dart';

/// Listen to Discovery Card changes and log [AnalyticsEvents].
@injectable
class LogDiscoveryCardAnalyticsUseCase extends UseCase<
    DiscoveryCardObservationPair, DiscoveryCardObservationPair> {
  final AnalyticsService _analyticsService;

  LogDiscoveryCardAnalyticsUseCase(this._analyticsService);

  @override
  Stream<DiscoveryCardObservationPair> transaction(
      DiscoveryCardObservationPair param) {
    final previousCard = param.first;
    final newCard = param.last;
    final isSwiped = newCard.value.document != previousCard.value.document;
    final isClicked = newCard.value.viewType != previousCard.value.viewType;

    if (isSwiped) {
      final event = SwipeCardAnalyticsEvent(previousCard);
      _analyticsService.logEvent(event);
    } else if (isClicked) {
      final event = ChangeCardViewTypeAnalyticsEvent(newCard);
      _analyticsService.logEvent(event);
    }

    return Stream.value(param);
  }
}
