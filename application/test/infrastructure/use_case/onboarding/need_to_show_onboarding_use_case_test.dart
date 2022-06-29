import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_status.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/domain/repository/bookmarks_repository.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/need_to_show_onboarding_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late NeedToShowOnboardingUseCase useCase;
  late AppStatusRepository appStatusRepository;
  late CollectionsRepository collectionsRepository;
  late BookmarksRepository bookmarksRepository;
  AppStatus appAppStatus = AppStatus.initial();

  void updateAppStatus({
    bool homeVerticalSwipeDone = true,
    bool homeSideSwipeDone = true,
    bool homeManageBookmarksDone = true,
    bool collectionsManageDone = true,
    numberOfSessions = 0,
  }) {
    appAppStatus = appAppStatus.copyWith(
        numberOfSessions: numberOfSessions,
        onboardingStatus: OnboardingStatus(
          homeVerticalSwipeDone: homeVerticalSwipeDone,
          homeSideSwipeDone: homeSideSwipeDone,
          homeManageBookmarksDone: homeManageBookmarksDone,
          collectionsManageDone: collectionsManageDone,
        ));
    when(appStatusRepository.appStatus).thenReturn(appAppStatus);
  }

  void updateCollectionsAndBookmarksCount({
    int collectionsCount = 0,
    int bookmarksCount = 0,
  }) {
    Collection createCollection() => Collection(
          id: UniqueId(),
          name: UniqueId().toString(),
          index: 0,
        );
    Bookmark createBookmark() => Bookmark(
          id: UniqueId(),
          collectionId: UniqueId(),
          image: null,
          title: UniqueId().toString(),
          provider: null,
          createdAt: DateTime.now().toIso8601String(),
          url: 'https://url_test.com',
        );
    when(collectionsRepository.getAll())
        .thenReturn(List.filled(collectionsCount, createCollection()));
    when(bookmarksRepository.getAll())
        .thenReturn(List.filled(bookmarksCount, createBookmark()));
  }

  setUp(() {
    appStatusRepository = MockAppStatusRepository();
    collectionsRepository = MockCollectionsRepository();
    bookmarksRepository = MockBookmarksRepository();

    useCase = NeedToShowOnboardingUseCase(
      appStatusRepository,
      collectionsRepository,
      bookmarksRepository,
    );
  });

  group('OnboardingType.homeVerticalSwipe', () {
    const type = OnboardingType.homeVerticalSwipe;
    tearDown(() {
      verifyZeroInteractions(collectionsRepository);
      verifyZeroInteractions(bookmarksRepository);
    });

    useCaseTest(
      'GIVEN homeVerticalSwipeDone == true THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeVerticalSwipeDone: true);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );

    useCaseTest(
      'GIVEN homeVerticalSwipeDone == false AND sessions == 0 THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeVerticalSwipeDone: false, numberOfSessions: 0);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );

    useCaseTest(
      'GIVEN homeVerticalSwipeDone == false AND sessions == 1 THEN yield true',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeVerticalSwipeDone: false, numberOfSessions: 1);
      },
      input: [type],
      expect: [
        useCaseSuccess(true),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );

    useCaseTest(
      'GIVEN homeVerticalSwipeDone == false AND sessions >1 THEN yield true',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeVerticalSwipeDone: false, numberOfSessions: 2);
      },
      input: [type],
      expect: [
        useCaseSuccess(true),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );
  });
  group('OnboardingType.homeHorizontalSwipe', () {
    const type = OnboardingType.homeHorizontalSwipe;
    tearDown(() {
      verifyZeroInteractions(collectionsRepository);
      verifyZeroInteractions(bookmarksRepository);
    });

    useCaseTest(
      'GIVEN homeSideSwipeDone == true THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeSideSwipeDone: true);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );

    useCaseTest(
      'GIVEN homeSideSwipeDone == false AND sessions == 0 THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeSideSwipeDone: false, numberOfSessions: 0);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );

    useCaseTest(
      'GIVEN homeSideSwipeDone == false AND sessions < 2 THEN yield true',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeSideSwipeDone: false, numberOfSessions: 1);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );

    useCaseTest(
      'GIVEN homeSideSwipeDone == false AND sessions ==2 THEN yield true',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeSideSwipeDone: false, numberOfSessions: 2);
      },
      input: [type],
      expect: [
        useCaseSuccess(true),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );

    useCaseTest(
      'GIVEN homeSideSwipeDone == false AND sessions >2 THEN yield true',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeSideSwipeDone: false, numberOfSessions: 3);
      },
      input: [type],
      expect: [
        useCaseSuccess(true),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );
  });
  group('OnboardingType.homeBookmarksManage', () {
    const type = OnboardingType.homeBookmarksManage;

    useCaseTest(
      'GIVEN homeManageBookmarksDone == true THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeManageBookmarksDone: true);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );
    useCaseTest(
      'GIVEN homeManageBookmarksDone == false AND sessionsCount < 5 THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeManageBookmarksDone: false, numberOfSessions: 4);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );
    useCaseTest(
      'GIVEN homeManageBookmarksDone == false AND sessionsCount >= 5 AND collectionsCount <=2 THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeManageBookmarksDone: false, numberOfSessions: 5);
        updateCollectionsAndBookmarksCount(collectionsCount: 2);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
          collectionsRepository.getAll(),
        ]);
        verifyZeroInteractions(bookmarksRepository);
      },
    );
    useCaseTest(
      'GIVEN homeManageBookmarksDone == false AND sessionsCount >= 5 AND collectionsCount > 2 AND bookmarksCount <= 5 THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeManageBookmarksDone: false, numberOfSessions: 5);
        updateCollectionsAndBookmarksCount(
          collectionsCount: 3,
          bookmarksCount: 5,
        );
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
          collectionsRepository.getAll(),
          bookmarksRepository.getAll(),
        ]);
      },
    );
    useCaseTest(
      'GIVEN homeManageBookmarksDone == false AND sessionsCount >= 5 AND collectionsCount > 2 AND bookmarksCount <= 5 THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(homeManageBookmarksDone: false, numberOfSessions: 5);
        updateCollectionsAndBookmarksCount(
          collectionsCount: 3,
          bookmarksCount: 6,
        );
      },
      input: [type],
      expect: [
        useCaseSuccess(true),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
          collectionsRepository.getAll(),
          bookmarksRepository.getAll(),
        ]);
      },
    );
  });
  group('OnboardingType.collectionsManage', () {
    const type = OnboardingType.collectionsManage;

    useCaseTest(
      'GIVEN collectionsManageDone == true THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(collectionsManageDone: true);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );
    useCaseTest(
      'GIVEN collectionsManageDone == false AND collectionsCount <=1 THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(collectionsManageDone: false);
        updateCollectionsAndBookmarksCount(collectionsCount: 1);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
          collectionsRepository.getAll(),
        ]);
        verifyZeroInteractions(bookmarksRepository);
      },
    );
    useCaseTest(
      'GIVEN collectionsManageDone == false AND collectionsCount > 1 THEN yield true',
      build: () => useCase,
      setUp: () {
        updateAppStatus(collectionsManageDone: false);
        updateCollectionsAndBookmarksCount(collectionsCount: 2);
      },
      input: [type],
      expect: [
        useCaseSuccess(true),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
          collectionsRepository.getAll(),
        ]);
        verifyZeroInteractions(bookmarksRepository);
      },
    );
  });
  group('OnboardingType.bookmarksManage', () {
    const type = OnboardingType.bookmarksManage;

    useCaseTest(
      'GIVEN collectionsManageDone == true THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(collectionsManageDone: true);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
        ]);
        verifyZeroInteractions(collectionsRepository);
        verifyZeroInteractions(bookmarksRepository);
      },
    );
    useCaseTest(
      'GIVEN collectionsManageDone == false AND bookmarksCount == 0 THEN yield false',
      build: () => useCase,
      setUp: () {
        updateAppStatus(collectionsManageDone: false);
        updateCollectionsAndBookmarksCount(bookmarksCount: 0);
      },
      input: [type],
      expect: [
        useCaseSuccess(false),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
          bookmarksRepository.getAll(),
        ]);
        verifyZeroInteractions(collectionsRepository);
      },
    );
    useCaseTest(
      'GIVEN collectionsManageDone == false AND bookmarksCount >= 1 THEN yield true',
      build: () => useCase,
      setUp: () {
        updateAppStatus(collectionsManageDone: false);
        updateCollectionsAndBookmarksCount(bookmarksCount: 1);
      },
      input: [type],
      expect: [
        useCaseSuccess(true),
      ],
      verify: (_) {
        verifyInOrder([
          appStatusRepository.appStatus,
          bookmarksRepository.getAll(),
        ]);
        verifyZeroInteractions(collectionsRepository);
      },
    );
  });
}
