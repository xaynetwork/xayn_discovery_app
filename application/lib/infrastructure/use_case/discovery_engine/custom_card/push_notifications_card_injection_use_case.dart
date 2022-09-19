import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/can_display_push_notifications_card_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/listen_push_notifications_conditions_use_case.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@lazySingleton
class PushNotificationsCardInjectionUseCase
    extends UseCase<PushNotificationsCardInjectionData, Set<Card>> {
  /// The [Document] which is a reference point in rebuilds, if not null,
  /// then we show the custom card always before this document.
  /// Note that we need to use a document as reference, because an index
  /// is not static, older cards are removed as you keep swiping down,
  /// thus a logical index is not kept.
  Document? nextDocumentSibling;
  final CanDisplayPushNotificationsCardUseCase
      _canDisplayPushNotificationsCardUseCase;

  PushNotificationsCardInjectionUseCase(
    this._canDisplayPushNotificationsCardUseCase,
  );

  @override
  Stream<Set<Card>> transaction(
      PushNotificationsCardInjectionData param) async* {
    final nextDocuments = param.currentCards
        .where((element) => element.document != null)
        .map((e) => e.document!);
    final canDisplay =
        await _canDisplayPushNotificationsCardUseCase.singleOutput(none);

    if (nextDocuments.isEmpty || canDisplay == false) {
      yield param.currentCards;
    } else {
      if (shouldMarkInjectionPoint(param)) {
        nextDocumentSibling = nextDocuments.last;
      }

      yield toCards(param.currentCards).toSet();
    }
  }

  @visibleForTesting
  bool shouldMarkInjectionPoint(PushNotificationsCardInjectionData data) =>
      nextDocumentSibling == null &&
      data.status == PushNotificationsConditionsStatus.reached;

  @visibleForTesting
  Iterable<Card> toCards(Iterable<Card> cards) sync* {
    for (final card in cards) {
      if (card.document == nextDocumentSibling) {
        yield const Card.other(CardType.pushNotifications);
      }

      yield card;
    }
  }
}

@immutable
class PushNotificationsCardInjectionData {
  final Set<Card> currentCards;
  final PushNotificationsConditionsStatus? status;

  const PushNotificationsCardInjectionData({
    required this.currentCards,
    PushNotificationsConditionsStatus? status,
  }) : status = status ?? PushNotificationsConditionsStatus.notReached;
}
