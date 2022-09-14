import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/get_push_notifications_status_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';

@lazySingleton
class PushNotificationsCardInjectionUseCase
    extends UseCase<PushNotificationsCardInjectionData, Set<Card>> {
  final FeatureManager featureManager;
  final GetPushNotificationsStatusUseCase getPushNotificationsStatusUseCase;

  PushNotificationsCardInjectionUseCase(
    this.featureManager,
    this.getPushNotificationsStatusUseCase,
  );

  @override
  Stream<Set<Card>> transaction(
      PushNotificationsCardInjectionData param) async* {
    final userDidChangePushNotifications =
        await getPushNotificationsStatusUseCase.singleOutput(none);

    if (userDidChangePushNotifications) {
      yield param.currentCards;
      return;
    }

    yield toCards(param.currentCards).toSet();
  }

  @visibleForTesting
  Iterable<Card> toCards(Set<Card> cards) sync* {
    yield const Card.other(CardType.pushNotifications);

    for (final card in cards) {
      yield card;
    }
  }
}

@immutable
class PushNotificationsCardInjectionData {
  final Set<Card> currentCards;

  int get currentDocumentsCount =>
      currentCards.where((it) => it.document != null).length;

  const PushNotificationsCardInjectionData({
    required this.currentCards,
  });
}
