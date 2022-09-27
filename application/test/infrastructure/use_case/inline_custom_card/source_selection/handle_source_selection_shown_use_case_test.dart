import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/source_selection/handle_source_selection_shown_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late HandleSourceSelectionShownUseCase handleSourceSelectionShownUseCase;

  appStatusRepository = MockAppStatusRepository();
  handleSourceSelectionShownUseCase =
      HandleSourceSelectionShownUseCase(appStatusRepository);

  final initialAppStatus = AppStatus.initial();

  const initialSourceSelection = InLineCard.initial(CardType.sourceSelection);

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  late AppStatus updatedAppStatus;

  useCaseTest(
    'WHEN called THEN update the source selection object into the db with increased number of time shown',
    setUp: () {
      final updatedSourceSelection = initialSourceSelection.copyWith(
          numberOfTimesShown: initialSourceSelection.numberOfTimesShown + 1);

      updatedAppStatus = initialAppStatus.copyWith(
          cta: initialAppStatus.cta.copyWith(
        sourceSelection: updatedSourceSelection,
      ));
    },
    build: () => handleSourceSelectionShownUseCase,
    input: [none],
    verify: (_) {
      verify(appStatusRepository.save(updatedAppStatus)).called(1);
    },
    expect: [
      useCaseSuccess(none),
    ],
  );
}
