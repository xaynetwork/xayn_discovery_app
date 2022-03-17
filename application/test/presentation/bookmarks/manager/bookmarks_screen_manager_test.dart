import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_base.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_state.dart';
import 'package:xayn_discovery_app/presentation/bookmark/util/bookmark_errors_enum_mapper.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

import '../../test_utils/utils.dart';
import 'bookmarks_screen_manager_test.mocks.dart';

@GenerateMocks([
  GetAllBookmarksUseCase,
  ListenBookmarksUseCase,
  RemoveBookmarkUseCase,
  MoveBookmarkUseCase,
  BookmarkErrorsEnumMapper,
  DateTimeHandler,
])
void main() {
  late MockListenBookmarksUseCase listenBookmarksUseCase;
  late MockRemoveBookmarkUseCase removeBookmarkUseCase;
  late MockMoveBookmarkUseCase moveBookmarkUseCase;
  late MockHapticFeedbackMediumUseCase hapticFeedbackMediumUseCase;
  late MockBookmarkErrorsEnumMapper bookmarkErrorsEnumMapper;
  late MockDateTimeHandler dateTimeHandler;
  late BookmarksScreenManager bookmarksScreenManager;
  late BookmarksScreenNavActions bookmarksScreenNavActions;
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

  setUp(() {
    listenBookmarksUseCase = MockListenBookmarksUseCase();
    removeBookmarkUseCase = MockRemoveBookmarkUseCase();
    moveBookmarkUseCase = MockMoveBookmarkUseCase();
    hapticFeedbackMediumUseCase = MockHapticFeedbackMediumUseCase();
    bookmarkErrorsEnumMapper = MockBookmarkErrorsEnumMapper();
    bookmarksScreenNavActions = MockBookmarksScreenNavActions();
    dateTimeHandler = MockDateTimeHandler();

    when(listenBookmarksUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);

    when(listenBookmarksUseCase.transaction(any)).thenAnswer(
      (_) => Stream.value(ListenBookmarksUseCaseOut(bookmarks, 'Read Later')),
    );

    bookmarksScreenManager = BookmarksScreenManager(
      listenBookmarksUseCase,
      removeBookmarkUseCase,
      moveBookmarkUseCase,
      hapticFeedbackMediumUseCase,
      bookmarkErrorsEnumMapper,
      dateTimeHandler,
      bookmarksScreenNavActions,
    );

    populatedState =
        BookmarksScreenState.populated(bookmarks, timestamp, 'Read Later');

    when(dateTimeHandler.getDateTimeNow()).thenReturn(timestamp);
  });

  group(
    'Bookmarks screen manager',
    () {
      blocTest<BookmarksScreenManager, BookmarksScreenState>(
        'WHEN manager is created THEN state is initial ',
        build: () => bookmarksScreenManager,

        /// Here we check that the list of bookmark is not empty because when
        /// the manager is created the initial state is not actually emitted
        verify: (manager) => expect(manager.state.bookmarks.isEmpty, true),
      );

      blocTest<BookmarksScreenManager, BookmarksScreenState>(
        'WHEN enteringScreen method has been called THEN call the usecase and emit populate state ',
        build: () => bookmarksScreenManager,
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
        'WHEN moveBookmark method has been called THEN call the usecase ',
        setUp: () => when(
          moveBookmarkUseCase.call(
            MoveBookmarkUseCaseIn(
              bookmarkId: bookmarks.first.id,
              collectionId: collectionId,
            ),
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
        build: () => bookmarksScreenManager,
        act: (manager) {
          manager.moveBookmark(
            bookmarkId: bookmarks.first.id,
            collectionId: collectionId,
          );
        },
        verify: (manager) {
          verifyInOrder([
            moveBookmarkUseCase.call(
              MoveBookmarkUseCaseIn(
                bookmarkId: bookmarks.first.id,
                collectionId: collectionId,
              ),
            ),
          ]);

          verifyNoMoreInteractions(moveBookmarkUseCase);
        },
      );

      blocTest<BookmarksScreenManager, BookmarksScreenState>(
        'WHEN moveBookmarkUseCase returns failure output THEN return current state with error message ',
        setUp: () {
          when(bookmarkErrorsEnumMapper.mapEnumToString(
            BookmarkUseCaseError.tryingToMoveBookmarkToNotExistingCollection,
          )).thenReturn(R.strings.errorMsgCollectionDoesntExist);
          when(
            moveBookmarkUseCase.call(
              MoveBookmarkUseCaseIn(
                bookmarkId: bookmarks.first.id,
                collectionId: collectionId,
              ),
            ),
          ).thenAnswer(
            (_) => Future.value(
              [
                const UseCaseResult.failure(
                  BookmarkUseCaseError
                      .tryingToMoveBookmarkToNotExistingCollection,
                  null,
                )
              ],
            ),
          );
        },
        build: () => bookmarksScreenManager,
        act: (manager) {
          manager.moveBookmark(
            bookmarkId: bookmarks.first.id,
            collectionId: collectionId,
          );
        },
        verify: (manager) {
          verifyInOrder([
            moveBookmarkUseCase.call(
              MoveBookmarkUseCaseIn(
                bookmarkId: bookmarks.first.id,
                collectionId: collectionId,
              ),
            ),
          ]);

          verifyNoMoreInteractions(moveBookmarkUseCase);
          expect(
            manager.state.errorMsg,
            equals(
              R.strings.errorMsgCollectionDoesntExist,
            ),
          );
        },
      );

      blocTest<BookmarksScreenManager, BookmarksScreenState>(
        'WHEN moveBookmark method has been called THEN call the usecase ',
        setUp: () => when(
          moveBookmarkUseCase.call(
            MoveBookmarkUseCaseIn(
              bookmarkId: bookmarks.first.id,
              collectionId: collectionId,
            ),
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
        build: () => bookmarksScreenManager,
        act: (manager) {
          manager.moveBookmark(
            bookmarkId: bookmarks.first.id,
            collectionId: collectionId,
          );
        },
        verify: (manager) {
          verifyInOrder([
            moveBookmarkUseCase.call(
              MoveBookmarkUseCaseIn(
                bookmarkId: bookmarks.first.id,
                collectionId: collectionId,
              ),
            ),
          ]);

          verifyNoMoreInteractions(moveBookmarkUseCase);
        },
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
        build: () => bookmarksScreenManager,
        act: (manager) {
          manager.removeBookmark(
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
        build: () => bookmarksScreenManager,
        act: (manager) {
          manager.removeBookmark(
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
}
