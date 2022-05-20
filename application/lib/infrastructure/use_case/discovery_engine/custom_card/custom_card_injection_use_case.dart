import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class CustomCardInjectionUseCase extends UseCase<Set<Document>, Set<Card>> {
  /// The [Document] which is a reference point in rebuilds, if not null,
  /// then we show the custom card always before this document.
  /// Note that we need to use a document as reference, because an index
  /// is not static, older cards are removed as you keep swiping down,
  /// thus a logical index is not kept.
  Document? nextDocumentSibling;

  @override
  Stream<Set<Card>> transaction(Set<Document> param) async* {
    // todo This use case should act upon the logic, which triggers whenever
    // we should show the survey.
    // When the trigger occurs, simply follow the code below:

    // --- fake trigger code start
    if (nextDocumentSibling == null && param.length > 2) {
      nextDocumentSibling = param.elementAt(2);
    }
    // --- fake trigger code end

    yield _toCards(param).toSet();
  }

  Iterable<Card> _toCards(Set<Document> documents) sync* {
    for (final document in documents) {
      if (document == nextDocumentSibling) {
        yield const Card.other(CardType.survey);
      }

      yield Card.document(document);
    }
  }
}
