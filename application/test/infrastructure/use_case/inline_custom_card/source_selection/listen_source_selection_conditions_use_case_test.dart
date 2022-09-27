import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/source_selection/listen_source_selection_conditions_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockUserInteractionsRepository userInteractionsRepository;
  late MockAppStatusRepository appStatusRepository;
  late MockCanDisplaySourceSelectionUseCase canDisplaySourceSelectionUseCase;
  late ListenSourceConditionsStatusUseCase listenSourceConditionsStatusUseCase;

  canDisplaySourceSelectionUseCase = MockCanDisplaySourceSelectionUseCase();
  userInteractionsRepository = MockUserInteractionsRepository();
  appStatusRepository = MockAppStatusRepository();
  listenSourceConditionsStatusUseCase = ListenSourceConditionsStatusUseCase(
    userInteractionsRepository,
    appStatusRepository,
    canDisplaySourceSelectionUseCase,
  );

  when(canDisplaySourceSelectionUseCase.singleOutput(none))
      .thenAnswer((_) async => true);

  final initialUserInteractions = UserInteractions.initial();

  group(
    'number of sessions did NOT reach threshold',
    () {
      test(
        'WHEN number of sessions is zero THEN conditions have not been reached',
        () {
          final result = listenSourceConditionsStatusUseCase
              .performSourceSelectionConditionsStatusCheck(
            numberOfSessions: 0,
            userInteractions: initialUserInteractions,
          );

          expect(result, SourceSelectionConditionsStatus.notReached);
        },
      );
    },
  );

  group(
    'number of sessions reached the threshold',
    () {
      test(
        'WHEN number of scrolls did NOT reach threshold THEN conditions have not been reached',
        () {
          final updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfScrollsPerSession: 4,
            numberOfSourcesTrusted: 0,
          );

          final result = listenSourceConditionsStatusUseCase
              .performSourceSelectionConditionsStatusCheck(
            numberOfSessions: 1,
            userInteractions: updatedUserInteractions,
          );

          expect(result, SourceSelectionConditionsStatus.notReached);
        },
      );

      test(
        'WHEN number of scrolls reached threshold but numberOfSources is more than 1 THEN conditions have not been reached',
        () {
          final updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfScrollsPerSession: 11,
            numberOfSourcesTrusted: 1,
          );
          final result = listenSourceConditionsStatusUseCase
              .performSourceSelectionConditionsStatusCheck(
            numberOfSessions: 1,
            userInteractions: updatedUserInteractions,
          );

          expect(result, SourceSelectionConditionsStatus.notReached);
        },
      );

      test(
        'WHEN number of scrolls reached threshold but numberOfSources is equal to 0 THEN conditions have been reached',
        () {
          final updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfScrollsPerSession: 11,
            numberOfSourcesTrusted: 0,
          );
          final result = listenSourceConditionsStatusUseCase
              .performSourceSelectionConditionsStatusCheck(
            numberOfSessions: 1,
            userInteractions: updatedUserInteractions,
          );

          expect(result, SourceSelectionConditionsStatus.reached);
        },
      );
    },
  );

  useCaseTest(
    'WHEN use case called THEN verify the watch method is called',
    setUp: () {
      when(canDisplaySourceSelectionUseCase.singleOutput(none))
          .thenAnswer((_) async => true);
      when(userInteractionsRepository.watch()).thenAnswer(
        (_) => Stream.value(
          ChangedEvent(
            id: UserInteractions.globalId,
            newObject: UserInteractions.initial(),
          ),
        ),
      );
    },
    build: () => listenSourceConditionsStatusUseCase,
    input: [none],
    verify: (_) {
      verifyInOrder([
        userInteractionsRepository.watch(),
      ]);
      verifyNoMoreInteractions(userInteractionsRepository);
    },
  );

  useCaseTest(
    'WHEN canDisplaySourceSelectionUseCase returns false THEN yield false',
    setUp: () {
      when(canDisplaySourceSelectionUseCase.singleOutput(none))
          .thenAnswer((_) async => false);
    },
    build: () => listenSourceConditionsStatusUseCase,
    input: [none],
    verify: (_) {
      verifyNoMoreInteractions(userInteractionsRepository);
    },
    expect: [
      useCaseSuccess(SourceSelectionConditionsStatus.notReached),
    ],
  );
}
