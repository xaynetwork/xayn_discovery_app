import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/domain/repository/feed_settings_repository.dart';
import 'package:xayn_discovery_app/domain/repository/user_interactions_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/country_selection/can_display_country_selection_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/inline_card_utils.dart';

const int _kNumOfSessionsThreshold = 1;
const int _kNumOfScrollsThreshold = 5;
const int _kNumberOfSelectedCountriesThreshold = 1;

@injectable
class ListenCountryConditionsStatusUseCase
    extends UseCase<None, CountrySelectionConditionsStatus> {
  final UserInteractionsRepository userInteractionsRepository;
  final AppStatusRepository appStatusRepository;
  final FeedSettingsRepository feedSettingsRepository;
  final CanDisplayCountrySelectionUseCase canDisplayCountrySelectionUseCase;

  ListenCountryConditionsStatusUseCase(
    this.userInteractionsRepository,
    this.appStatusRepository,
    this.feedSettingsRepository,
    this.canDisplayCountrySelectionUseCase,
  );

  @override
  Stream<CountrySelectionConditionsStatus> transaction(None param) async* {
    final canDisplay =
        await canDisplayCountrySelectionUseCase.singleOutput(none);
    if (!canDisplay) {
      yield CountrySelectionConditionsStatus.notReached;
      return;
    }

    yield* userInteractionsRepository.watch().map(
      (_) {
        final userInteractions = userInteractionsRepository.userInteractions;
        final numberOfSelectedCountries =
            feedSettingsRepository.settings.feedMarkets.length;
        final numberOfScrolls = userInteractions.numberOfScrollsPerSession;
        final numberOfSessions = appStatusRepository.appStatus.numberOfSessions;

        return performCountrySelectionConditionsStatusCheck(
          numberOfScrolls: numberOfScrolls,
          numberOfSessions: numberOfSessions,
          numberOfSelectedCountries: numberOfSelectedCountries,
        );
      },
    );
  }

  @visibleForTesting
  CountrySelectionConditionsStatus
      performCountrySelectionConditionsStatusCheck({
    required int numberOfSelectedCountries,
    required int numberOfScrolls,
    required int numberOfSessions,
  }) {
    // The conditions are listed in the description of the following task
    // https://xainag.atlassian.net/browse/TB-4049
    final hasExceededSwipeCount = InLineCardUtils.hasExceededSwipeCount(
        numberOfScrolls, _kNumOfScrollsThreshold);

    if (numberOfSessions <= _kNumOfSessionsThreshold &&
        hasExceededSwipeCount &&
        numberOfSelectedCountries <= _kNumberOfSelectedCountriesThreshold) {
      return CountrySelectionConditionsStatus.reached;
    }

    return CountrySelectionConditionsStatus.notReached;
  }
}

enum CountrySelectionConditionsStatus { notReached, reached }
