import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/listen_survey_conditions_use_case.dart';

import '../../../test_utils/mocks.mocks.dart';

void main() {
  late MockUserInteractionsRepository userInteractionsRepository;
  late MockAppStatusRepository appStatusRepository;
  late ListenSurveyConditionsStatusUseCase listenSurveyConditionsStatusUseCase;

  userInteractionsRepository = MockUserInteractionsRepository();
  appStatusRepository = MockAppStatusRepository();
  listenSurveyConditionsStatusUseCase = ListenSurveyConditionsStatusUseCase(
      userInteractionsRepository, appStatusRepository);

  final initialUserInteractions = UserInteractions.initial();

  group(
    'number of sessions did NOT reach threshold',
    () {
      test(
        'WHEN number of sessions is zero THEN conditions have not been reached',
        () {
          final result = listenSurveyConditionsStatusUseCase
              .performSurveyConditionsStatusCheck(
            numberOfSessions: 0,
            userInteractions: initialUserInteractions,
          );

          expect(result, SurveyConditionsStatus.notReached);
        },
      );

      test(
        'WHEN number of sessions is one THEN conditions have not been reached',
        () {
          final result = listenSurveyConditionsStatusUseCase
              .performSurveyConditionsStatusCheck(
            numberOfSessions: 1,
            userInteractions: initialUserInteractions,
          );

          expect(result, SurveyConditionsStatus.notReached);
        },
      );
    },
  );

  group(
    'number of user interactions did NOT reach threshold',
    () {
      test(
        'WHEN method called THEN conditions have not been reached',
        () {
          final result = listenSurveyConditionsStatusUseCase
              .performSurveyConditionsStatusCheck(
            numberOfSessions: 2,
            userInteractions: initialUserInteractions,
          );

          expect(result, SurveyConditionsStatus.notReached);
        },
      );
    },
  );

  group(
    'number of user interactions reached the threshold',
    () {
      test(
        'WHEN number of scrolls did NOT reach threshold THEN conditions have not been reached',
        () {
          final updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfScrolls: 4,
            numberOfArticlesBookmarked: 7,
          );

          final result = listenSurveyConditionsStatusUseCase
              .performSurveyConditionsStatusCheck(
            numberOfSessions: 2,
            userInteractions: updatedUserInteractions,
          );

          expect(result, SurveyConditionsStatus.notReached);
        },
      );

      test(
        'WHEN number of scrolls is equal or greater than the number of interactions THEN conditions have not been reached',
        () {
          final updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfScrolls: 11,
            numberOfArticlesBookmarked: 0,
          );
          final result = listenSurveyConditionsStatusUseCase
              .performSurveyConditionsStatusCheck(
            numberOfSessions: 2,
            userInteractions: updatedUserInteractions,
          );

          expect(result, SurveyConditionsStatus.notReached);
        },
      );

      test(
        'WHEN number of scrolls reached the threshold and at least another different interaction has been made THEN conditions have been reached',
        () {
          final updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfScrolls: 12,
            numberOfArticlesBookmarked: 1,
          );
          final result = listenSurveyConditionsStatusUseCase
              .performSurveyConditionsStatusCheck(
            numberOfSessions: 2,
            userInteractions: updatedUserInteractions,
          );

          expect(result, SurveyConditionsStatus.reached);
        },
      );
    },
  );

  useCaseTest(
    'WHEN use case called THEN verify the watch method is called',
    setUp: () {
      when(userInteractionsRepository.watch()).thenAnswer(
        (_) => Stream.value(
          ChangedEvent(
            id: UserInteractions.globalId,
            newObject: UserInteractions.initial(),
          ),
        ),
      );
    },
    build: () => listenSurveyConditionsStatusUseCase,
    input: [none],
    verify: (_) {
      verifyInOrder([
        userInteractionsRepository.watch(),
      ]);
      verifyNoMoreInteractions(userInteractionsRepository);
    },
  );
}
