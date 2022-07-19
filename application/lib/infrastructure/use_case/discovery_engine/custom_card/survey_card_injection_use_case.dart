import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
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
    final nextDocuments = param.nextDocuments;

    if (nextDocuments == null) {
      yield param.currentCards;
    } else {
      if (shouldMarkInjectionPoint(param)) {
        nextDocumentSibling = nextDocuments.last;
      }

      yield toCards(nextDocuments).toSet();
    }
  }

  @visibleForTesting
  bool shouldMarkInjectionPoint(SurveyCardInjectionData data) =>
      nextDocumentSibling == null &&
      data.status == SurveyConditionsStatus.reached &&
      data.nextDocumentsCount > data.currentDocumentsCount &&
      data.nextDocumentsCount > 2;

  @visibleForTesting
  Iterable<Card> toCards(Set<Document> documents) sync* {
    for (final document in documents) {
      if (document == nextDocumentSibling) {
        yield const Card.other(CardType.survey);
      }

      yield Card.document(document);
    }
  }
}

@immutable
class SurveyCardInjectionData {
  final Set<Card> currentCards;
  final Set<Document>? nextDocuments;
  final SurveyConditionsStatus status;

  int get currentDocumentsCount =>
      currentCards.where((it) => it.document != null).length;

  int get nextDocumentsCount => nextDocuments?.length ?? 0;

  const SurveyCardInjectionData({
    required this.currentCards,
    this.nextDocuments,
    SurveyConditionsStatus? status,
  }) : status = status ?? SurveyConditionsStatus.notReached;
}
