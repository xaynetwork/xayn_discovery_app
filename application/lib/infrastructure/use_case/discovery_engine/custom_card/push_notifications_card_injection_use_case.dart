import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/get_push_notifications_status_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/listen_push_notifications_conditions_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
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
  final FeatureManager featureManager;
  final GetPushNotificationsStatusUseCase getPushNotificationsStatusUseCase;

  PushNotificationsCardInjectionUseCase(
    this.featureManager,
    this.getPushNotificationsStatusUseCase,
  );

  @override
  Stream<Set<Card>> transaction(
      PushNotificationsCardInjectionData param) async* {
    final nextDocuments = param.nextDocuments;
    final userDidChangePushNotifications =
        await getPushNotificationsStatusUseCase.singleOutput(none);

    if (Platform.isAndroid ||
        nextDocuments == null ||
        userDidChangePushNotifications ||
        !featureManager.areRemoteNotificationsEnabled) {
      yield param.currentCards;
    } else {
      if (shouldMarkInjectionPoint(param)) {
        nextDocumentSibling = nextDocuments.last;
      }

      yield toCards(nextDocuments).toSet();
    }
  }

  @visibleForTesting
  bool shouldMarkInjectionPoint(PushNotificationsCardInjectionData data) =>
      nextDocumentSibling == null &&
      data.status == PushNotificationsConditionsStatus.reached;

  @visibleForTesting
  Iterable<Card> toCards(Set<Document> documents) sync* {
    for (final document in documents) {
      if (document == nextDocumentSibling) {
        yield const Card.other(CardType.pushNotifications);
      }

      yield Card.document(document);
    }
  }
}

@immutable
class PushNotificationsCardInjectionData {
  final Set<Card> currentCards;
  final Set<Document>? nextDocuments;
  final PushNotificationsConditionsStatus? status;

  const PushNotificationsCardInjectionData({
    required this.currentCards,
    this.nextDocuments,
    PushNotificationsConditionsStatus? status,
  }) : status = status ?? PushNotificationsConditionsStatus.notReached;
}
