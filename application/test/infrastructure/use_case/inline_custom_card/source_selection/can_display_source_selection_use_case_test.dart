import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/item_renderer/card.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/inline_card/inline_card.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/source_selection/can_display_source_selection_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockAppStatusRepository appStatusRepository;
  late MockFeatureManager featureManager;
  late CanDisplaySourceSelectionUseCase canDisplaySourceSelectionUseCase;

  appStatusRepository = MockAppStatusRepository();
  featureManager = MockFeatureManager();
  canDisplaySourceSelectionUseCase = CanDisplaySourceSelectionUseCase(
    appStatusRepository,
    featureManager,
  );

  final initialAppStatus = AppStatus.initial();

  const initialSourceSelection = InLineCard.initial(CardType.sourceSelection);

  final sourceSelectionShownOnce =
      initialSourceSelection.copyWith(numberOfTimesShown: 1);

  final sourceSelectionShownTwice =
      initialSourceSelection.copyWith(numberOfTimesShown: 2);

  when(appStatusRepository.appStatus).thenReturn(initialAppStatus);

  group(
    'CanDisplaySourceSelectionUseCase',
    () {
      group(
        'Feature flag ENABLED',
        () {
          useCaseTest(
            'WHEN sourceSelection has been shown already twice THEN return false',
            setUp: () {
              when(featureManager.isSourceSelectionInLineCardEnabled)
                  .thenReturn(true);
              when(appStatusRepository.appStatus).thenReturn(
                initialAppStatus.copyWith(
                  cta: initialAppStatus.cta
                      .copyWith(sourceSelection: sourceSelectionShownTwice),
                ),
              );
            },
            build: () => canDisplaySourceSelectionUseCase,
            input: [none],
            expect: [
              useCaseSuccess(false),
            ],
          );

          useCaseTest(
            'WHEN sourceSelection has been shown once THEN return true',
            setUp: () {
              when(featureManager.isSourceSelectionInLineCardEnabled)
                  .thenReturn(true);
              when(appStatusRepository.appStatus).thenReturn(
                initialAppStatus.copyWith(
                  cta: initialAppStatus.cta.copyWith(
                    sourceSelection: sourceSelectionShownOnce,
                  ),
                ),
              );
            },
            build: () => canDisplaySourceSelectionUseCase,
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
              when(featureManager.isSourceSelectionInLineCardEnabled)
                  .thenReturn(false);
            },
            build: () => canDisplaySourceSelectionUseCase,
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
