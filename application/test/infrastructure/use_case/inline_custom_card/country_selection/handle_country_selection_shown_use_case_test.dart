import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/country_selection/handle_country_selection_shown_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late HandleCountrySelectionShownUseCase handleCountrySelectionShownUseCase;

  appStatusRepository = MockAppStatusRepository();
  handleCountrySelectionShownUseCase =
      HandleCountrySelectionShownUseCase(appStatusRepository);

  final initialAppStatus = AppStatus.initial();

  const initialCountrySelection = InLineCard.initial(CardType.countrySelection);

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  late AppStatus updatedAppStatus;

  useCaseTest(
    'WHEN called THEN update the country selection object into the db with increased number of time shown',
    setUp: () {
      final updatedCountrySelection = initialCountrySelection.copyWith(
          numberOfTimesShown: initialCountrySelection.numberOfTimesShown + 1);

      updatedAppStatus = initialAppStatus.copyWith(
          cta: initialAppStatus.cta.copyWith(
        countrySelection: updatedCountrySelection,
      ));
    },
    build: () => handleCountrySelectionShownUseCase,
    input: [none],
    verify: (_) {
      verify(appStatusRepository.save(updatedAppStatus)).called(1);
    },
    expect: [
      useCaseSuccess(none),
    ],
  );
}
