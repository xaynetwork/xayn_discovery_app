import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/bookmark_deleted_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_state.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockListenBookmarksUseCase listenBookmarksUseCase;
  late MockOverlayManager<BookmarksScreenState> overlayManager;
  late MockRemoveBookmarkUseCase removeBookmarkUseCase;
  late MockSendAnalyticsUseCase sendAnalyticsUseCase;
  late MockHapticFeedbackMediumUseCase hapticFeedbackMediumUseCase;
  late MockBookmarkErrorsEnumMapper bookmarkErrorsEnumMapper;
  late MockDateTimeHandler dateTimeHandler;
  late BookmarksScreenNavActions bookmarksScreenNavActions;
  late MockNeedToShowOnboardingUseCase needToShowOnboardingUseCase;
  late MockMarkOnboardingTypeCompletedUseCase
      markOnboardingTypeCompletedUseCase;
  late BookmarksScreenState populatedState;
  final timestamp = DateTime.now();
  final collectionId = UniqueId();
  final provider = DocumentProvider(
      name: 'Provider name', favicon: 'https://www.foo.com/favicon.ico');

  final bookmarks = [
    Bookmark(
      id: UniqueId(),
      collectionId: collectionId,
      title: 'Bookmark1 title',
      image: Uint8List.fromList([1, 2, 3]),
      provider: provider,
      createdAt: DateTime.now().toUtc().toString(),
    )
  ];

  BookmarksScreenManager create({
    bool setMockOverlayManager = false,
  }) {
    final manager = BookmarksScreenManager(
      listenBookmarksUseCase,
      removeBookmarkUseCase,
      hapticFeedbackMediumUseCase,
      bookmarkErrorsEnumMapper,
      dateTimeHandler,
      bookmarksScreenNavActions,
      needToShowOnboardingUseCase,
      markOnboardingTypeCompletedUseCase,
      sendAnalyticsUseCase,
    );
    if (setMockOverlayManager) {
      manager.setOverlayManager(overlayManager);
    }
    return manager;
  }

  setUp(() {
    overlayManager = MockOverlayManager();
    listenBookmarksUseCase = MockListenBookmarksUseCase();
    removeBookmarkUseCase = MockRemoveBookmarkUseCase();
    sendAnalyticsUseCase = MockSendAnalyticsUseCase();
    hapticFeedbackMediumUseCase = MockHapticFeedbackMediumUseCase();
    bookmarkErrorsEnumMapper = MockBookmarkErrorsEnumMapper();
    bookmarksScreenNavActions = MockBookmarksScreenNavActions();
    needToShowOnboardingUseCase = MockNeedToShowOnboardingUseCase();
    markOnboardingTypeCompletedUseCase =
        MockMarkOnboardingTypeCompletedUseCase();
    dateTimeHandler = MockDateTimeHandler();

    when(listenBookmarksUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);

    when(listenBookmarksUseCase.transaction(any)).thenAnswer(
      (_) => Stream.value(ListenBookmarksUseCaseOut(bookmarks, 'Read Later')),
    );

    populatedState =
        BookmarksScreenState.populated(bookmarks, timestamp, 'Read Later');

    when(dateTimeHandler.getDateTimeNow()).thenReturn(timestamp);

    when(sendAnalyticsUseCase.call(any)).thenAnswer((_) async => [
          UseCaseResult.success(
            BookmarkDeletedEvent(
              fromDefaultCollection: true,
            ),
          )
        ]);
  });

  group(
    'Bookmarks screen manager',
    () {
      blocTest<BookmarksScreenManager, BookmarksScreenState>(
        'WHEN manager is created THEN state is initial ',
        build: () => create(),

        /// Here we check that the list of bookmark is not empty because when
        /// the manager is created the initial state is not actually emitted
        verify: (manager) => expect(manager.state.bookmarks.isEmpty, true),
      );

      blocTest<BookmarksScreenManager, BookmarksScreenState>(
        'WHEN enteringScreen method has been called THEN call the usecase and emit populate state ',
        build: () => create(),
        act: (manager) {
          manager.enteringScreen(collectionId);
        },
        verify: (manager) {
          verifyInOrder([
            listenBookmarksUseCase.transform(any),
            listenBookmarksUseCase.transaction(
                ListenBookmarksUseCaseIn(collectionId: collectionId)),
          ]);
          verifyNoMoreInteractions(listenBookmarksUseCase);
        },
        expect: () => [populatedState],
      );

      blocTest<BookmarksScreenManager, BookmarksScreenState>(
        'WHEN removeBookmark method has been called THEN call the usecase ',
        setUp: () => when(
          removeBookmarkUseCase.call(
            bookmarks.first.id,
          ),
        ).thenAnswer(
          (_) => Future.value(
            [
              UseCaseResult.success(
                bookmarks.first,
              )
            ],
          ),
        ),
        build: () => create(),
        act: (manager) {
          manager.onDeleteSwipe(
            bookmarks.first.id,
          );
        },
        verify: (manager) {
          verifyInOrder([
            removeBookmarkUseCase.call(
              bookmarks.first.id,
            ),
          ]);

          verifyNoMoreInteractions(removeBookmarkUseCase);
        },
      );

      blocTest<BookmarksScreenManager, BookmarksScreenState>(
        'WHEN removeBookmark returns failure output THEN return current state with error message  ',
        setUp: () {
          when(bookmarkErrorsEnumMapper.mapEnumToString(
            BookmarkUseCaseError.tryingToRemoveNotExistingBookmark,
          )).thenReturn(R.strings.errorMsgBookmarkDoesntExist);
          when(
            removeBookmarkUseCase.call(
              bookmarks.first.id,
            ),
          ).thenAnswer(
            (_) => Future.value(
              [
                const UseCaseResult.failure(
                  BookmarkUseCaseError.tryingToRemoveNotExistingBookmark,
                  null,
                )
              ],
            ),
          );
        },
        build: () => create(),
        act: (manager) {
          manager.onDeleteSwipe(
            bookmarks.first.id,
          );
        },
        verify: (manager) {
          verifyInOrder([
            removeBookmarkUseCase.call(
              bookmarks.first.id,
            ),
          ]);

          verifyNoMoreInteractions(removeBookmarkUseCase);
          expect(
            manager.state.errorMsg,
            equals(
              R.strings.errorMsgBookmarkDoesntExist,
            ),
          );
        },
      );
    },
  );

  blocTest<BookmarksScreenManager, BookmarksScreenState>(
    'GIVEN true WHEN _needToShowOnboardingUseCase is called THEN overlay manager called',
    build: () => create(setMockOverlayManager: true),
    setUp: () {
      when(needToShowOnboardingUseCase
              .singleOutput(OnboardingType.bookmarksManage))
          .thenAnswer((_) async => true);
    },
    act: (manager) => manager.checkIfNeedToShowOnboarding(),
    verify: (manager) {
      verifyInOrder([
        needToShowOnboardingUseCase
            .singleOutput(OnboardingType.bookmarksManage),
        overlayManager.show(any),
      ]);
      verifyNoMoreInteractions(needToShowOnboardingUseCase);
      verifyNoMoreInteractions(manager.overlayManager);
    },
  );

  blocTest<BookmarksScreenManager, BookmarksScreenState>(
    'GIVEN false WHEN _needToShowOnboardingUseCase is called THEN overlay manager NOT called',
    build: () => create(setMockOverlayManager: true),
    setUp: () {
      when(needToShowOnboardingUseCase
              .singleOutput(OnboardingType.bookmarksManage))
          .thenAnswer((_) async => false);
    },
    act: (manager) => manager.checkIfNeedToShowOnboarding(),
    verify: (manager) {
      verify(needToShowOnboardingUseCase
          .singleOutput(OnboardingType.bookmarksManage));
      verifyNoMoreInteractions(needToShowOnboardingUseCase);
      verifyZeroInteractions(manager.overlayManager);
    },
  );
}
