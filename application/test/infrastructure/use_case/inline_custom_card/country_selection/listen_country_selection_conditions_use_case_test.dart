import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/inline_custom_card/country_selection/listen_country_selection_conditions_use_case.dart';

import '../../../../test_utils/mocks.mocks.dart';

void main() {
  late MockUserInteractionsRepository userInteractionsRepository;
  late MockAppStatusRepository appStatusRepository;
  late MockFeedSettingsRepository feedSettingsRepository;
  late MockCanDisplayCountrySelectionUseCase canDisplayCountrySelectionUseCase;
  late ListenCountryConditionsStatusUseCase
      listenCountryConditionsStatusUseCase;

  canDisplayCountrySelectionUseCase = MockCanDisplayCountrySelectionUseCase();
  userInteractionsRepository = MockUserInteractionsRepository();
  feedSettingsRepository = MockFeedSettingsRepository();
  appStatusRepository = MockAppStatusRepository();
  listenCountryConditionsStatusUseCase = ListenCountryConditionsStatusUseCase(
    userInteractionsRepository,
    appStatusRepository,
    feedSettingsRepository,
    canDisplayCountrySelectionUseCase,
  );

  when(canDisplayCountrySelectionUseCase.singleOutput(none))
      .thenAnswer((_) async => true);

  group(
    'number of sessions reached the threshold',
    () {
      test(
        'WHEN number of scrolls did NOT reach threshold THEN conditions have not been reached',
        () {
          final result = listenCountryConditionsStatusUseCase
              .performCountrySelectionConditionsStatusCheck(
            numberOfSelectedCountries: 1,
            numberOfScrolls: 3,
            numberOfSessions: 1,
          );

          expect(result, CountrySelectionConditionsStatus.notReached);
        },
      );

      test(
        'WHEN number of scrolls reached threshold but numberOfCountries is more than 1 THEN conditions have not been reached',
        () {
          final result = listenCountryConditionsStatusUseCase
              .performCountrySelectionConditionsStatusCheck(
            numberOfSelectedCountries: 2,
            numberOfScrolls: 5,
            numberOfSessions: 1,
          );

          expect(result, CountrySelectionConditionsStatus.notReached);
        },
      );

      test(
        'WHEN number of scrolls reached threshold but numberOfSources is equal to 1 THEN conditions have been reached',
        () {
          final result = listenCountryConditionsStatusUseCase
              .performCountrySelectionConditionsStatusCheck(
            numberOfSelectedCountries: 1,
            numberOfScrolls: 5,
            numberOfSessions: 1,
          );

          expect(result, CountrySelectionConditionsStatus.reached);
        },
      );
    },
  );

  useCaseTest(
    'WHEN use case called THEN verify the watch method is called',
    setUp: () {
      when(canDisplayCountrySelectionUseCase.singleOutput(none))
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
    build: () => listenCountryConditionsStatusUseCase,
    input: [none],
    verify: (_) {
      verifyInOrder([
        userInteractionsRepository.watch(),
        userInteractionsRepository.userInteractions,
      ]);
      verifyNoMoreInteractions(userInteractionsRepository);
    },
  );

  useCaseTest(
    'WHEN canDisplayCountrySelectionUseCase returns false THEN yield false',
    setUp: () {
      when(canDisplayCountrySelectionUseCase.singleOutput(none))
          .thenAnswer((_) async => false);
    },
    build: () => listenCountryConditionsStatusUseCase,
    input: [none],
    verify: (_) {
      verifyNoMoreInteractions(userInteractionsRepository);
    },
    expect: [
      useCaseSuccess(CountrySelectionConditionsStatus.notReached),
    ],
  );
}
