import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const int _skipEvery = 5;

@lazySingleton
class AdCardInjectionUseCase extends UseCase<Set<Card>, Set<Card>> {
  final FeatureManager featureManager;
  final Set<DocumentId> _buffer = <DocumentId>{};

  AdCardInjectionUseCase(this.featureManager);

  @override
  Stream<Set<Card>> transaction(Set<Card> param) async* {
    if (!featureManager.areAdsEnabled) yield param;

    final documents = param
        .where((it) => it.type == CardType.document)
        .map((it) => it.document!)
        .toSet();

    _buffer.addAll(documents.map((it) => it.documentId));

    yield toCards(param).toSet();
  }

  @visibleForTesting
  Iterable<Card> toCards(Set<Card> cards) sync* {
    for (final card in cards) {
      yield card;

      if (card.type == CardType.document) {
        final document = card.requireDocument;

        if (shouldShowAdAfter(document.documentId)) {
          yield Card.other(CardType.ad, document.documentId.uniqueId);
        }
      }
    }
  }

  @visibleForTesting
  bool shouldShowAdAfter(DocumentId documentId) {
    final list = _buffer.toList(growable: false);
    final index = list.indexOf(documentId);
    final isFirstGroup = index == 0;
    final isAtSkipLocation = index % _skipEvery == 0;

    return !isFirstGroup && isAtSkipLocation;
  }
}
