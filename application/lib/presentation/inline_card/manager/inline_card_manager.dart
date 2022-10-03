import 'dart:async';

import 'package:collection/collection.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/country/country.dart';
import 'package:xayn_discovery_app/domain/model/push_notifications/push_notifications_conditions_status.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feed_settings/get_selected_countries_list_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/country_selection/handle_country_selection_card_clicked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/country_selection/handle_country_selection_shown_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/country_selection/listen_country_selection_conditions_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/inline_card_injection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/get_push_notifications_conditions_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/handle_push_notifications_card_clicked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/push_notifications/listen_push_notifications_conditions_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/source_selection/handle_source_selection_card_clicked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/source_selection/handle_source_selection_shown_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/source_selection/listen_source_selection_conditions_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/survey_banner/handle_survey_banner_clicked_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/survey_banner/handle_survey_banner_shown_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/survey_banner/listen_survey_conditions_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/push_notifications/handle_push_notifications_shown_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

import 'inline_card_state.dart';

abstract class InLineNavActions {
  void onManageSourcesPressed();

  void onManageCountriesPressed();
}

@injectable
class InLineCardManager extends Cubit<InLineCardState>
    with UseCaseBlocHelper<InLineCardState>
    implements InLineNavActions {
  final ListenSurveyConditionsStatusUseCase listenSurveyConditionsStatusUseCase;
  final ListenCountryConditionsStatusUseCase
      listenCountryConditionsStatusUseCase;
  final ListenSourceConditionsStatusUseCase listenSourceConditionsStatusUseCase;
  final ListenPushNotificationsConditionsStatusUseCase
      listenPushNotificationsConditionsStatusUseCase;
  final GetPushNotificationsConditionsStatusUseCase
      getPushNotificationsConditionsStatusUseCase;
  final HandleSurveyBannerClickedUseCase handleSurveyBannerClickedUseCase;
  final HandleSourceSelectionClickedUseCase handleSourceSelectionClickedUseCase;
  final HandleCountrySelectionClickedUseCase
      handleCountrySelectionClickedUseCase;
  final HandleSurveyBannerShownUseCase handleSurveyBannerShownUseCase;
  final HandleSourceSelectionShownUseCase handleSourceSelectionShownUseCase;
  final HandleCountrySelectionShownUseCase handleCountrySelectionShownUseCase;
  final HandlePushNotificationsShownUseCase handlePushNotificationsShownUseCase;
  final HandlePushNotificationsCardClickedUseCase
      handlePushNotificationsCardClickedUseCase;
  final InLineCardInjectionUseCase inLineCardInjectionUseCase;
  final FeatureManager featureManager;
  final InLineNavActions inLineNavActions;
  final GetSelectedCountriesListUseCase getSelectedCountriesListUseCase;
  late final UseCaseValueStream<Set<Country>> getSelectedCountriesListHandler;

  InLineCardManager(
    this.listenSurveyConditionsStatusUseCase,
    this.listenCountryConditionsStatusUseCase,
    this.listenSourceConditionsStatusUseCase,
    this.handleSurveyBannerClickedUseCase,
    this.handleCountrySelectionClickedUseCase,
    this.handleSourceSelectionClickedUseCase,
    this.handleSurveyBannerShownUseCase,
    this.handleSourceSelectionShownUseCase,
    this.handleCountrySelectionShownUseCase,
    this.handlePushNotificationsShownUseCase,
    this.inLineCardInjectionUseCase,
    this.featureManager,
    this.inLineNavActions,
    this.getSelectedCountriesListUseCase,
    this.listenPushNotificationsConditionsStatusUseCase,
    this.getPushNotificationsConditionsStatusUseCase,
    this.handlePushNotificationsCardClickedUseCase,
  ) : super(InLineCardState.initial()) {
    init();
  }

  late final UseCaseValueStream<SurveyConditionsStatus>
      surveyConditionStatusStream = consume(
    listenSurveyConditionsStatusUseCase,
    initialData: none,
  );

  late final UseCaseValueStream<PushNotificationsConditionsStatus>
      pushNotificationsConditionStatusStream = consume(
    listenPushNotificationsConditionsStatusUseCase,
    initialData: none,
  );

  late final UseCaseValueStream<CountrySelectionConditionsStatus>
      countrySelectionConditionStatusStream = consume(
    listenCountryConditionsStatusUseCase,
    initialData: none,
  );

  late final UseCaseValueStream<SourceSelectionConditionsStatus>
      sourceSelectionConditionStatusStream = consume(
    listenSourceConditionsStatusUseCase,
    initialData: none,
  );

  void init() {
    getSelectedCountriesListHandler =
        consume(getSelectedCountriesListUseCase, initialData: none);
  }

  void handleInLineCardTapped(CardType cardType) async {
    switch (cardType) {
      case CardType.document:
        throw _CustomFeedCardForDocumentException();
      case CardType.survey:
        handleSurveyBannerClickedUseCase(none);
        break;
      case CardType.sourceSelection:
        handleSourceSelectionClickedUseCase(none);
        onManageSourcesPressed();
        break;
      case CardType.countrySelection:
        handleCountrySelectionClickedUseCase(none);
        onManageCountriesPressed();
        break;
      case CardType.pushNotifications:
        final result =
            await handlePushNotificationsCardClickedUseCase.singleOutput(none);
        // If the user enabled notifications, dismiss the card
        if (result) scheduleComputeState(() {});
        break;
    }
  }

  void handleInLineCardShown(CardType cardType) {
    switch (cardType) {
      case CardType.document:
        throw _CustomFeedCardForDocumentException();
      case CardType.survey:
        handleSurveyBannerShownUseCase(none);
        break;
      case CardType.sourceSelection:
        handleSourceSelectionShownUseCase(none);
        break;
      case CardType.countrySelection:
        handleCountrySelectionShownUseCase(none);
        break;
      case CardType.pushNotifications:
        handlePushNotificationsShownUseCase(none);
        break;
    }
  }

  Future<Set<Card>> maybeAddInLineCard({
    required Set<Card> currentCards,
    required Set<Document>? nextDocuments,
  }) async =>
      inLineCardInjectionUseCase.singleOutput(
        InLineCardInjectionData(
          currentCards: currentCards,
          nextDocuments: nextDocuments,
          cardType: state.cardType,
        ),
      );

  Future<String?> getCountryName() async {
    final selectedCountries =
        await getSelectedCountriesListUseCase.singleOutput(none);
    return selectedCountries.singleOrNull?.name;
  }

  @override
  Future<InLineCardState?> computeState() async => fold5(
        surveyConditionStatusStream,
        countrySelectionConditionStatusStream,
        sourceSelectionConditionStatusStream,
        getSelectedCountriesListHandler,
        pushNotificationsConditionStatusStream,
      ).foldAll(
        (
          surveyConditionsStatus,
          countrySelectionConditionStatus,
          sourceSelectionConditionStatus,
          selectedCountries,
          _,
          errorReport,
        ) async {
          final pushNotificationsConditionStatus =
              await getPushNotificationsConditionsStatusUseCase
                  .singleOutput(none);
          return InLineCardState.populated(
            surveyConditionsStatus: surveyConditionsStatus,
            countrySelectionConditionsStatus: countrySelectionConditionStatus,
            sourceSelectionConditionsStatus: sourceSelectionConditionStatus,
            pushNotificationsConditionsStatus: pushNotificationsConditionStatus,
            selectedCountryName: state.selectedCountryName ??
                selectedCountries?.singleOrNull?.name,
          );
        },
      );

  @override
  void onManageCountriesPressed() =>
      inLineNavActions.onManageCountriesPressed();

  @override
  void onManageSourcesPressed() => inLineNavActions.onManageSourcesPressed();
}

class _CustomFeedCardForDocumentException implements Exception {
  _CustomFeedCardForDocumentException();

  @override
  String toString() =>
      'CardType = document operations should not be handled in inline card manager';
}
