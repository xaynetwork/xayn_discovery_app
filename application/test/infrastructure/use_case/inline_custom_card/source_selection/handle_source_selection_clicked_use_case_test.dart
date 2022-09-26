import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/source_selection/handle_source_selection_card_clicked_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late HandleSourceSelectionClickedUseCase handleSourceSelectionClickedUseCase;

  appStatusRepository = MockAppStatusRepository();
  handleSourceSelectionClickedUseCase = HandleSourceSelectionClickedUseCase(
    appStatusRepository,
  );

  final initialAppStatus = AppStatus.initial();

  const initialSourceSelection = InLineCard.initial(CardType.sourceSelection);

  final clickedSourceSelection =
      initialSourceSelection.copyWith(hasBeenClicked: true);

  final appStatusSourceSelectionClicked = initialAppStatus.copyWith(
    cta: initialAppStatus.cta.copyWith(
      sourceSelection: clickedSourceSelection,
    ),
  );

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  group(
    'WHEN user is subscribed',
    () {
      useCaseTest(
        'WHEN use case is called THEN update the source selection object into the db with clicked flag set to true',
        build: () => handleSourceSelectionClickedUseCase,
        input: [none],
        verify: (_) {
          verify(appStatusRepository.save(appStatusSourceSelectionClicked))
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
        'WHEN use case is called THEN update the source selection into the db with clicked flag set to true',
        build: () => handleSourceSelectionClickedUseCase,
        input: [none],
        verify: (_) {
          verify(appStatusRepository.save(appStatusSourceSelectionClicked))
              .called(1);
        },
        expect: [
          useCaseSuccess(none),
        ],
      );
    },
  );
}
