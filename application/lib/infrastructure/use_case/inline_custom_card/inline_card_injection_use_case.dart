import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@lazySingleton
class InLineCardInjectionUseCase
    extends UseCase<InLineCardInjectionData, Set<Card>> {
  /// The [Document] which is a reference point in rebuilds, if not null,
  /// then we show the custom card always before this document.
  /// Note that we need to use a document as reference, because an index
  /// is not static, older cards are removed as you keep swiping down,
  /// thus a logical index is not kept.
  Set<DocumentReferenceWithCardType> referenceDocuments = {};

  InLineCardInjectionUseCase();

  @override
  Stream<Set<Card>> transaction(InLineCardInjectionData param) async* {
    final nextDocuments = param.nextDocuments;
    final cardType = param.cardType;
    if (nextDocuments == null) {
      yield param.currentCards;
    } else {
      if (shouldMarkInjectionPoint(param)) {
        final document = param.currentDocument ?? nextDocuments.first;
        final referenceDocument =
            DocumentReferenceWithCardType(document, cardType!);
        referenceDocuments.add(referenceDocument);
      }

      yield toCards(nextDocuments, cardType).toSet();
    }
  }

  @visibleForTesting
  bool shouldMarkInjectionPoint(InLineCardInjectionData data) =>
      data.cardType != null &&
      data.nextDocuments!.isNotEmpty &&
      !referenceDocuments.any((it) => it.cardType == data.cardType);

  @visibleForTesting
  Iterable<Card> toCards(Set<Document> documents, CardType? cardType) sync* {
    for (final document in documents) {
      final isPreviouslyReferenced = referenceDocuments.any(
        (it) => it.document.documentId == document.documentId,
      );
      if (isPreviouslyReferenced) {
        final cardType = referenceDocuments
            .firstWhere((it) => it.document == document)
            .cardType;
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
  final CardType? cardType;
  final Document? currentDocument;

  int get currentDocumentsCount =>
      currentCards.where((it) => it.document != null).length;

  int get nextDocumentsCount => nextDocuments?.length ?? 0;

  const InLineCardInjectionData({
    required this.currentCards,
    this.nextDocuments,
    required this.cardType,
    required this.currentDocument,
  });
}

@immutable
class DocumentReferenceWithCardType {
  final Document document;
  final CardType cardType;

  const DocumentReferenceWithCardType(this.document, this.cardType);
}
