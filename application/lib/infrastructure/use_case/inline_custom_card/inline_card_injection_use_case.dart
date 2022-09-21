import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@lazySingleton
class InLineCardInjectionUseCase
    extends UseCase<InLineCardInjectionData, Set<Card>> {
  /// The [Document] which is a reference point in rebuilds, if not null,
  /// then we show the custom card always before this document.
  /// Note that we need to use a document as reference, because an index
  /// is not static, older cards are removed as you keep swiping down,
  /// thus a logical index is not kept.
  Document? nextDocumentSibling;
  final FeatureManager featureManager;

  InLineCardInjectionUseCase(this.featureManager);

  @override
  Stream<Set<Card>> transaction(InLineCardInjectionData param) async* {
    final nextDocuments = param.nextDocuments;
    final cardType = param.cardType;

    if (nextDocuments == null) {
      yield param.currentCards;
    } else {
      if (shouldMarkInjectionPoint(param)) {
        nextDocumentSibling = nextDocuments.last;
      }

      yield toCards(nextDocuments, cardType).toSet();
    }
  }

  @visibleForTesting
  bool shouldMarkInjectionPoint(InLineCardInjectionData data) =>
      nextDocumentSibling == null &&
      data.nextDocumentsCount > data.currentDocumentsCount &&
      data.nextDocumentsCount > 2;

  @visibleForTesting
  Iterable<Card> toCards(Set<Document> documents, CardType cardType) sync* {
    for (final document in documents) {
      if (document == nextDocumentSibling) {
        yield Card.other(cardType);
      }

      yield Card.document(document);
    }
  }
}

@immutable
class InLineCardInjectionData {
  final Set<Card> currentCards;
  final Set<Document>? nextDocuments;
  final CardType cardType;

  int get currentDocumentsCount =>
      currentCards.where((it) => it.document != null).length;

  int get nextDocumentsCount => nextDocuments?.length ?? 0;

  const InLineCardInjectionData({
    required this.currentCards,
    this.nextDocuments,
    required this.cardType,
  });
}
