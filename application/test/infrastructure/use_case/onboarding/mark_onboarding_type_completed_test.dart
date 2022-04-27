import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/none.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_status.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/mark_onboarding_type_completed.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MarkOnboardingTypeCompletedUseCase useCase;
  late AppStatusRepository appStatusRepository;

  final initialAppStatus = AppStatus.initial();

  AppStatus getAppStatus({
    bool homeVerticalSwipeDone = false,
    bool homeSideSwipeDone = false,
    bool homeManageBookmarksDone = false,
    bool collectionsManageDone = false,
  }) =>
      initialAppStatus.copyWith(
          onboardingStatus: OnboardingStatus(
        homeVerticalSwipeDone: homeVerticalSwipeDone,
        homeSideSwipeDone: homeSideSwipeDone,
        homeManageBookmarksDone: homeManageBookmarksDone,
        collectionsManageDone: collectionsManageDone,
      ));
  setUp(() {
    appStatusRepository = MockAppStatusRepository();

    useCase = MarkOnboardingTypeCompletedUseCase(
      appStatusRepository,
    );

    when(appStatusRepository.appStatus).thenReturn(getAppStatus());
  });

  group('onboarding not completed', () {
    useCaseTest(
      'GIVEN OnboardingType.homeVerticalSwipe THEN save true to homeVerticalSwipeDone',
      build: () => useCase,
      input: [OnboardingType.homeVerticalSwipe],
      expect: [useCaseSuccess(none)],
      verify: (_) => verifyInOrder([
        appStatusRepository.appStatus,
        appStatusRepository.save(getAppStatus(homeVerticalSwipeDone: true)),
      ]),
    );

    useCaseTest(
      'GIVEN OnboardingType.homeHorizontalSwipe THEN save true to homeSideSwipeDone',
      build: () => useCase,
      input: [OnboardingType.homeHorizontalSwipe],
      expect: [useCaseSuccess(none)],
      verify: (_) => verifyInOrder([
        appStatusRepository.appStatus,
        appStatusRepository.save(getAppStatus(homeSideSwipeDone: true)),
      ]),
    );

    useCaseTest(
      'GIVEN OnboardingType.homeBookmarksManage THEN save true to homeManageBookmarksDone',
      build: () => useCase,
      input: [OnboardingType.homeBookmarksManage],
      expect: [useCaseSuccess(none)],
      verify: (_) => verifyInOrder([
        appStatusRepository.appStatus,
        appStatusRepository.save(getAppStatus(homeManageBookmarksDone: true)),
      ]),
    );

    useCaseTest(
      'GIVEN OnboardingType.collectionsManage THEN save true to collectionsManageDone',
      build: () => useCase,
      input: [OnboardingType.collectionsManage],
      expect: [useCaseSuccess(none)],
      verify: (_) => verifyInOrder([
        appStatusRepository.appStatus,
        appStatusRepository.save(getAppStatus(collectionsManageDone: true)),
      ]),
    );

    useCaseTest(
      'GIVEN OnboardingType.bookmarksManage THEN save true to collectionsManageDone',
      build: () => useCase,
      input: [OnboardingType.bookmarksManage],
      expect: [useCaseSuccess(none)],
      verify: (_) => verifyInOrder([
        appStatusRepository.appStatus,
        appStatusRepository.save(getAppStatus(collectionsManageDone: true)),
      ]),
    );
  });

  group('onboarding completed', () {
    final completed = getAppStatus(
      homeVerticalSwipeDone: true,
      homeSideSwipeDone: true,
      homeManageBookmarksDone: true,
      collectionsManageDone: true,
    );
    setUp(() {
      when(appStatusRepository.appStatus).thenReturn(completed);
    });
    for (final type in OnboardingType.values) {
      useCaseTest(
        'GIVEN $type WHEN onboarding for it completed THEN do not update repository',
        build: () => useCase,
        input: [type],
        expect: [useCaseSuccess(none)],
        verify: (_) {
          verifyInOrder([appStatusRepository.appStatus]);
          verifyNoMoreInteractions(appStatusRepository);
        },
      );
    }
  });
}
