import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/country_selection/listen_country_selection_conditions_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/source_selection/listen_source_selection_conditions_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/survey_banner/listen_survey_conditions_use_case.dart';

part 'inline_card_state.freezed.dart';

/// The state of the [InLineCardManager].
@freezed
class InLineCardState with _$InLineCardState {
  const InLineCardState._();

  const factory InLineCardState({
    @Default(SurveyConditionsStatus.notReached)
        SurveyConditionsStatus surveyConditionsStatus,
    @Default(CountrySelectionConditionsStatus.notReached)
        CountrySelectionConditionsStatus countrySelectionConditionsStatus,
    @Default(SourceSelectionConditionsStatus.notReached)
        SourceSelectionConditionsStatus sourceSelectionConditionsStatus,
    String? selectedCountryName,
  }) = _InLineCardState;

  factory InLineCardState.initial() => const InLineCardState();

  factory InLineCardState.populated({
    SurveyConditionsStatus? surveyConditionsStatus,
    CountrySelectionConditionsStatus? countrySelectionConditionsStatus,
    SourceSelectionConditionsStatus? sourceSelectionConditionsStatus,
    String? selectedCountryName,
  }) =>
      InLineCardState(
        surveyConditionsStatus:
            surveyConditionsStatus ?? SurveyConditionsStatus.notReached,
        countrySelectionConditionsStatus: countrySelectionConditionsStatus ??
            CountrySelectionConditionsStatus.notReached,
        sourceSelectionConditionsStatus: sourceSelectionConditionsStatus ??
            SourceSelectionConditionsStatus.notReached,
        selectedCountryName: selectedCountryName,
      );

  bool get isAnyConditionReached =>
      surveyConditionsStatus == SurveyConditionsStatus.reached ||
      countrySelectionConditionsStatus ==
          CountrySelectionConditionsStatus.reached ||
      sourceSelectionConditionsStatus ==
          SourceSelectionConditionsStatus.reached;
}

extension InLineCardStateExtension on InLineCardState {
  CardType? get cardType {
    if (surveyConditionsStatus == SurveyConditionsStatus.reached) {
      return CardType.survey;
    }
    if (countrySelectionConditionsStatus ==
        CountrySelectionConditionsStatus.reached) {
      return CardType.countrySelection;
    }
    if (sourceSelectionConditionsStatus ==
        SourceSelectionConditionsStatus.reached) {
      return CardType.sourceSelection;
    }
    return null;
  }
}
