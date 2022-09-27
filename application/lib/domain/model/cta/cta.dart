import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';

@immutable
class CTA extends Equatable {
  final InLineCard surveyBanner;
  final InLineCard countrySelection;
  final InLineCard sourceSelection;
  final InLineCard pushNotifications;

  const CTA({
    required this.surveyBanner,
    required this.countrySelection,
    required this.sourceSelection,
    required this.pushNotifications,
  });

  const CTA.initial()
      : surveyBanner = const InLineCard.initial(CardType.survey),
        countrySelection = const InLineCard.initial(CardType.countrySelection),
        sourceSelection = const InLineCard.initial(CardType.sourceSelection),
        pushNotifications =
            const InLineCard.initial(CardType.pushNotifications);

  CTA copyWith({
    InLineCard? surveyBanner,
    InLineCard? countrySelection,
    InLineCard? sourceSelection,
    InLineCard? pushNotifications,
  }) =>
      CTA(
        surveyBanner: surveyBanner ?? this.surveyBanner,
        countrySelection: countrySelection ?? this.countrySelection,
        sourceSelection: sourceSelection ?? this.sourceSelection,
        pushNotifications: pushNotifications ?? this.pushNotifications,
      );

  @override
  List<Object?> get props => [
        surveyBanner,
        countrySelection,
        sourceSelection,
        pushNotifications,
      ];
}
