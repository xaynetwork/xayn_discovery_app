import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/listen_survey_conditions_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@lazySingleton
class SurveyCardInjectionUseCase
    extends UseCase<SurveyCardInjectionData, Set<Card>> {
  /// The [Document] which is a reference point in rebuilds, if not null,
  /// then we show the custom card always before this document.
  /// Note that we need to use a document as reference, because an index
  /// is not static, older cards are removed as you keep swiping down,
  /// thus a logical index is not kept.
  Document? nextDocumentSibling;
  final FeatureManager featureManager;

  SurveyCardInjectionUseCase(this.featureManager);

  @override
  Stream<Set<Card>> transaction(SurveyCardInjectionData param) async* {
    if (param.nextDocumentsCount == 0) {
      yield param.cards;
    } else {
      if (shouldMarkInjectionPoint(param)) {
        nextDocumentSibling = param.lastDocument;
      }

      yield toCards(param.cards).toSet();
    }
  }

  @visibleForTesting
  bool shouldMarkInjectionPoint(SurveyCardInjectionData data) =>
      nextDocumentSibling == null &&
      data.status == SurveyConditionsStatus.reached &&
      data.nextDocumentsCount > data.currentDocumentsCount &&
      data.nextDocumentsCount > 2;

  @visibleForTesting
  Iterable<Card> toCards(Set<Card> cards) sync* {
    for (final card in cards) {
      if (card.type == CardType.document &&
          card.requireDocument == nextDocumentSibling) {
        yield Card.other(
            CardType.survey, card.requireDocument.documentId.uniqueId);
      }

      yield card;
    }
  }
}

@immutable
class SurveyCardInjectionData {
  final Set<Card> cards;
  final Set<Document> _documents;
  final SurveyConditionsStatus status;

  int get currentDocumentsCount =>
      cards.where((it) => it.document != null).length;

  int get nextDocumentsCount => _documents.length;

  Document get lastDocument => _documents.last;

  SurveyCardInjectionData({
    required this.cards,
    SurveyConditionsStatus? status,
  })  : status = status ?? SurveyConditionsStatus.notReached,
        _documents = cards
            .where((it) => it.type == CardType.document)
            .map((it) => it.document!)
            .toSet();
}
