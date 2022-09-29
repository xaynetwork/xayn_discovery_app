import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/mapper.dart';

@singleton
class InLineCardMapper extends Mapper<InLineCard, DbEntityMap> {
  const InLineCardMapper();

  @override
  DbEntityMap map(InLineCard input) => {
        InLineCardFields.numberOfTimesShown: input.numberOfTimesShown,
        InLineCardFields.hasBeenClicked: input.hasBeenClicked,
        InLineCardFields.lastSessionNumberWhenShown:
            input.lastSessionNumberWhenShown,
      };
}

@singleton
class DbEntityMapToSurveyInLineCardMapper
    extends _DbEntityMapToInLineCardMapper {
  const DbEntityMapToSurveyInLineCardMapper() : super(CardType.survey);
}

@singleton
class DbEntityMapToSourceSelectionInLineCardMapper
    extends _DbEntityMapToInLineCardMapper {
  const DbEntityMapToSourceSelectionInLineCardMapper()
      : super(CardType.sourceSelection);
}

@singleton
class DbEntityMapToCountrySelectionInLineCardMapper
    extends _DbEntityMapToInLineCardMapper {
  const DbEntityMapToCountrySelectionInLineCardMapper()
      : super(CardType.countrySelection);
}

@singleton
class DbEntityMapToPushNotificationsInLineCardMapper
    extends _DbEntityMapToInLineCardMapper {
  const DbEntityMapToPushNotificationsInLineCardMapper()
      : super(CardType.pushNotifications);
}

class _DbEntityMapToInLineCardMapper extends Mapper<DbEntityMap?, InLineCard> {
  final CardType cardType;

  const _DbEntityMapToInLineCardMapper(this.cardType);

  @override
  InLineCard map(Map? input) {
    if (input == null) return InLineCard.initial(cardType);

    final numberOfTimesShown = input[InLineCardFields.numberOfTimesShown] ?? 0;
    final hasSurveyBannerBeenClicked =
        input[InLineCardFields.hasBeenClicked] ?? false;
    final lastSessionNumberWhenShown =
        input[InLineCardFields.lastSessionNumberWhenShown] ?? 0;

    return InLineCard(
      numberOfTimesShown: numberOfTimesShown,
      hasBeenClicked: hasSurveyBannerBeenClicked,
      lastSessionNumberWhenShown: lastSessionNumberWhenShown,
      cardType: cardType,
    );
  }
}

abstract class InLineCardFields {
  InLineCardFields._();

  static const numberOfTimesShown = 0;
  static const hasBeenClicked = 1;
  static const lastSessionNumberWhenShown = 2;
}
