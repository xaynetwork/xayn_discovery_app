import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/country_selection/can_display_country_selection_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late MockFeatureManager featureManager;
  late CanDisplayCountrySelectionUseCase canDisplayCountrySelectionUseCase;

  appStatusRepository = MockAppStatusRepository();
  featureManager = MockFeatureManager();
  canDisplayCountrySelectionUseCase = CanDisplayCountrySelectionUseCase(
    appStatusRepository,
    featureManager,
  );

  final initialAppStatus = AppStatus.initial();

  const initialCountrySelection = InLineCard.initial(CardType.countrySelection);

  final countrySelectionShownOnce =
      initialCountrySelection.copyWith(numberOfTimesShown: 1);

  final countrySelectionShownTwice =
      initialCountrySelection.copyWith(numberOfTimesShown: 2);

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  group(
    'CanDisplayCountrySelectionUseCase',
    () {
      group(
        'Feature flag ENABLED',
        () {
          useCaseTest(
            'WHEN countrySelection has been shown already twice THEN return false',
            setUp: () {
              when(featureManager.isCountrySelectionInLineCardEnabled)
                  .thenReturn(true);
              when(appStatusRepository.appStatus).thenReturn(
                initialAppStatus.copyWith(
                  cta: initialAppStatus.cta
                      .copyWith(countrySelection: countrySelectionShownTwice),
                ),
              );
            },
            build: () => canDisplayCountrySelectionUseCase,
            input: [none],
            expect: [
              useCaseSuccess(false),
            ],
          );

          useCaseTest(
            'WHEN countrySelection has been shown once THEN return false',
            setUp: () {
              when(featureManager.isCountrySelectionInLineCardEnabled)
                  .thenReturn(true);
              when(appStatusRepository.appStatus).thenReturn(
                initialAppStatus.copyWith(
                  cta: initialAppStatus.cta.copyWith(
                    countrySelection: countrySelectionShownOnce,
                  ),
                ),
              );
            },
            build: () => canDisplayCountrySelectionUseCase,
            input: [none],
            expect: [
              useCaseSuccess(false),
            ],
          );

          useCaseTest(
            'WHEN countrySelection has not been shown THEN return true',
            setUp: () {
              when(featureManager.isCountrySelectionInLineCardEnabled)
                  .thenReturn(true);
              when(appStatusRepository.appStatus).thenReturn(
                initialAppStatus,
              );
            },
            build: () => canDisplayCountrySelectionUseCase,
            input: [none],
            expect: [
              useCaseSuccess(true),
            ],
          );
        },
      );
      group(
        'Feature flag DISABLED',
        () {
          useCaseTest(
            'WHEN calling the use case with flag disabled THEN return false',
            setUp: () {
              when(featureManager.isCountrySelectionInLineCardEnabled)
                  .thenReturn(false);
            },
            build: () => canDisplayCountrySelectionUseCase,
            input: [none],
            expect: [
              useCaseSuccess(false),
            ],
          );
        },
      );
    },
  );
}
