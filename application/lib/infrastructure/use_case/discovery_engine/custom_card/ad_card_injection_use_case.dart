import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const int _skipEvery = 5;

@lazySingleton
class AdCardInjectionUseCase extends UseCase<AdCardInjectionData, Set<Card>> {
  final FeatureManager featureManager;
  final Set<DocumentId> _buffer = <DocumentId>{};

  AdCardInjectionUseCase(this.featureManager);

  @override
  Stream<Set<Card>> transaction(AdCardInjectionData param) async* {
    final nextDocuments = param.nextDocuments;

    if (nextDocuments == null) {
      yield param.currentCards;
    } else {
      _buffer.addAll(nextDocuments.map((it) => it.documentId));

      yield toCards(nextDocuments).toSet();
    }
  }

  @visibleForTesting
  Iterable<Card> toCards(Set<Document> documents) sync* {
    final list = _buffer.toList(growable: false);

    for (final document in documents) {
      yield Card.document(document);

      if (list.indexOf(document.documentId) % _skipEvery == 0) {
        yield Card.other(CardType.ad, document.documentId.uniqueId);
      }
    }
  }
}

@immutable
class AdCardInjectionData {
  final Set<Card> currentCards;
  final Set<Document>? nextDocuments;

  int get currentDocumentsCount =>
      currentCards.where((it) => it.document != null).length;

  int get nextDocumentsCount => nextDocuments?.length ?? 0;

  const AdCardInjectionData({
    required this.currentCards,
    this.nextDocuments,
  });
}
