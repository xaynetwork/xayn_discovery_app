import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/topic/listen_topic_conditions_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockUserInteractionsRepository userInteractionsRepository;
  late MockAppStatusRepository appStatusRepository;
  late MockCanDisplayTopicsUseCase canDisplayTopicsUseCase;
  late ListenTopicsStatusUseCase listenTopicsStatusUseCase;

  canDisplayTopicsUseCase = MockCanDisplayTopicsUseCase();
  userInteractionsRepository = MockUserInteractionsRepository();
  appStatusRepository = MockAppStatusRepository();
  listenTopicsStatusUseCase = ListenTopicsStatusUseCase(
    userInteractionsRepository,
    appStatusRepository,
    canDisplayTopicsUseCase,
  );

  when(canDisplayTopicsUseCase.singleOutput(none))
      .thenAnswer((_) async => true);

  final initialUserInteractions = UserInteractions.initial();

  group(
    'number of sessions did reach threshold',
    () {
      test(
        'WHEN number of sessions is zero THEN conditions have been reached',
        () {
          final result =
              listenTopicsStatusUseCase.performTopicConditionsStatusCheck(
            numberOfSessions: 1,
            userInteractions: initialUserInteractions,
          );

          expect(result, TopicsConditionsStatus.reached);
        },
      );
    },
  );

  group(
    'number of sessions exceeded the threshold',
    () {
      test(
        'WHEN number of scrolls exceeded threshold THEN conditions have not been reached',
        () {
          final updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfScrollsPerSession: 1,
          );

          final result =
              listenTopicsStatusUseCase.performTopicConditionsStatusCheck(
            numberOfSessions: 2,
            userInteractions: updatedUserInteractions,
          );

          expect(result, TopicsConditionsStatus.notReached);
        },
      );

      test(
        'WHEN number of scrolls reached threshold THEN conditions have been reached',
        () {
          final updatedUserInteractions = initialUserInteractions.copyWith(
            numberOfScrollsPerSession: 4,
          );
          final result =
              listenTopicsStatusUseCase.performTopicConditionsStatusCheck(
            numberOfSessions: 2,
            userInteractions: updatedUserInteractions,
          );

          expect(result, TopicsConditionsStatus.reached);
        },
      );
    },
  );

  useCaseTest(
    'WHEN use case called THEN verify the watch method is called',
    setUp: () {
      when(canDisplayTopicsUseCase.singleOutput(none))
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
    build: () => listenTopicsStatusUseCase,
    input: [none],
    verify: (_) {
      verifyInOrder([
        userInteractionsRepository.watch(),
      ]);
      verifyNoMoreInteractions(userInteractionsRepository);
    },
  );

  useCaseTest(
    'WHEN canDisplayTopicsUseCase returns false THEN yield false',
    setUp: () {
      when(canDisplayTopicsUseCase.singleOutput(none))
          .thenAnswer((_) async => false);
    },
    build: () => listenTopicsStatusUseCase,
    input: [none],
    verify: (_) {
      verifyNoMoreInteractions(userInteractionsRepository);
    },
    expect: [
      useCaseSuccess(TopicsConditionsStatus.notReached),
    ],
  );
}
