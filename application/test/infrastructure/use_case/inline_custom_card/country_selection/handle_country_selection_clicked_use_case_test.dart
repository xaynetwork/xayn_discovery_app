import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/country_selection/handle_country_selection_card_clicked_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late HandleCountrySelectionClickedUseCase
      handleCountrySelectionClickedUseCase;

  appStatusRepository = MockAppStatusRepository();
  handleCountrySelectionClickedUseCase = HandleCountrySelectionClickedUseCase(
    appStatusRepository,
  );

  final initialAppStatus = AppStatus.initial();

  const initialCountrySelection = InLineCard.initial(CardType.countrySelection);

  final clickedCountrySelection =
      initialCountrySelection.copyWith(hasBeenClicked: true);

  final appStatusCountrySelectionClicked = initialAppStatus.copyWith(
    cta: initialAppStatus.cta.copyWith(
      countrySelection: clickedCountrySelection,
    ),
  );

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  group(
    'WHEN user is subscribed',
    () {
      useCaseTest(
        'WHEN use case is called THEN update the country selection object into the db with clicked flag set to true',
        build: () => handleCountrySelectionClickedUseCase,
        input: [none],
        verify: (_) {
          verify(appStatusRepository.save(appStatusCountrySelectionClicked))
              .called(1);
        },
        expect: [
          useCaseSuccess(none),
        ],
      );
    },
  );

  group(
    'WHEN user is NOT subscribed',
    () {
      useCaseTest(
        'WHEN use case is called THEN update the country selection into the db with clicked flag set to true',
        build: () => handleCountrySelectionClickedUseCase,
        input: [none],
        verify: (_) {
          verify(appStatusRepository.save(appStatusCountrySelectionClicked))
              .called(1);
        },
        expect: [
          useCaseSuccess(none),
        ],
      );
    },
  );
}
