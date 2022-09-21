import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';

@immutable
class InLineCard extends Equatable {
  final int numberOfTimesShown;
  final bool hasSurveyBannerBeenClicked;
  final int lastSessionNumberWhenShown;
  final CardType cardType;

  const InLineCard({
    required this.numberOfTimesShown,
    required this.hasSurveyBannerBeenClicked,
    required this.lastSessionNumberWhenShown,
    required this.cardType,
  });

  const InLineCard.survey({
    required this.numberOfTimesShown,
    required this.hasSurveyBannerBeenClicked,
    required this.lastSessionNumberWhenShown,
    this.cardType = CardType.survey,
  });

  const InLineCard.countrySelection({
    required this.numberOfTimesShown,
    required this.hasSurveyBannerBeenClicked,
    required this.lastSessionNumberWhenShown,
    this.cardType = CardType.countrySelection,
  });

  const InLineCard.sourceSelection({
    required this.numberOfTimesShown,
    required this.hasSurveyBannerBeenClicked,
    required this.lastSessionNumberWhenShown,
    this.cardType = CardType.sourceSelection,
  });

  const InLineCard.initial(this.cardType)
      : numberOfTimesShown = 0,
        hasSurveyBannerBeenClicked = false,
        lastSessionNumberWhenShown = 0;

  InLineCard copyWith({
    int? numberOfTimesShown,
    bool? hasSurveyBannerBeenClicked,
    int? lastSessionNumberWhenShown,
  }) =>
      InLineCard(
        numberOfTimesShown: numberOfTimesShown ?? this.numberOfTimesShown,
        hasSurveyBannerBeenClicked:
            hasSurveyBannerBeenClicked ?? this.hasSurveyBannerBeenClicked,
        lastSessionNumberWhenShown:
            lastSessionNumberWhenShown ?? this.lastSessionNumberWhenShown,
        cardType: cardType,
      );

  InLineCard clicked({required int sessionNumber}) => InLineCard(
        numberOfTimesShown: numberOfTimesShown,
        hasSurveyBannerBeenClicked: true,
        lastSessionNumberWhenShown: sessionNumber,
        cardType: cardType,
      );

  @override
  List<Object?> get props => [
        numberOfTimesShown,
        hasSurveyBannerBeenClicked,
        lastSessionNumberWhenShown,
        cardType,
      ];
}
