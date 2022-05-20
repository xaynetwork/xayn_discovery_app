import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class CustomCardInjectionUseCase extends UseCase<Set<Document>, Set<Card>> {
  @override
  Stream<Set<Card>> transaction(Set<Document> param) async* {
    // todo This use case should act upon the logic, which triggers whenever
    // we should show the survey.
    // When the trigger occurs, simply follow the code below:
    final transformed = param.map(Card.document).toSet();

    if (transformed.length >= 2) {
      final customCardInjectedList = transformed.toList()
        ..insert(2, const Card.other(CardType.survey));

      yield customCardInjectedList.toSet();
    } else {
      yield transformed;
    }
  }
}
