import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_bookmarks_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/handlers.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_manager.dart';
import 'package:xayn_discovery_app/presentation/bookmark/manager/bookmarks_screen_state.dart';

import 'bookmarks_screen_manager_test.mocks.dart';

@GenerateMocks([
  GetAllBookmarksUseCase,
  ListenBookmarksUseCase,
  RemoveBookmarkUseCase,
  MoveBookmarkUseCase,
  DateTimeHandler,
])
void main() {
  late MockListenBookmarksUseCase listenBookmarksUseCase;
  late MockRemoveBookmarkUseCase removeBookmarkUseCase;
  late MockMoveBookmarkUseCase moveBookmarkUseCase;
  late MockDateTimeHandler dateTimeHandler;
  late BookmarksScreenManager bookmarksScreenManager;
  late BookmarksScreenState populatedState;
  final timestamp = DateTime.now();
  final collectionId = UniqueId();

  final bookmarks = [
    Bookmark(
      id: UniqueId(),
      collectionId: collectionId,
      title: 'Bookmark1 title',
      image: Uint8List.fromList([1, 2, 3]),
      providerName: 'Provider name',
      providerThumbnail: Uint8List.fromList([4, 5, 6]),
      createdAt: DateTime.now().toUtc().toString(),
    )
  ];

  setUp(() {
    listenBookmarksUseCase = MockListenBookmarksUseCase();
    removeBookmarkUseCase = MockRemoveBookmarkUseCase();
    moveBookmarkUseCase = MockMoveBookmarkUseCase();
    dateTimeHandler = MockDateTimeHandler();

    when(listenBookmarksUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);

    when(listenBookmarksUseCase.transaction(any)).thenAnswer(
      (_) => Stream.value(ListenBookmarksUseCaseOut(bookmarks)),
    );

    bookmarksScreenManager = BookmarksScreenManager(
      listenBookmarksUseCase,
      removeBookmarkUseCase,
      moveBookmarkUseCase,
      dateTimeHandler,
    );
    populatedState = BookmarksScreenState.populated(bookmarks, timestamp);

    when(dateTimeHandler.getDateTimeNow()).thenReturn(timestamp);
  });

  group(
    'Bookmarks screen manager',
    () {
      blocTest<BookmarksScreenManager, BookmarksScreenState>(
        'WHEN manager is created THEN emit initial state ',
        build: () => bookmarksScreenManager,
        verify: (manager) => expect(manager.state.bookmarks.isEmpty, true),
        expect: () => [],
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
          moveBookmarkUseCase.singleOutput(
            MoveBookmarkUseCaseParam(
              bookmarkId: bookmarks.first.id,
              collectionId: collectionId,
            ),
          ),
        ).thenAnswer((_) => Future.value(bookmarks.first)),
        build: () => bookmarksScreenManager,
        act: (manager) {
          manager.moveBookmark(
            bookmarkId: bookmarks.first.id,
            collectionId: collectionId,
          );
        },
        verify: (manager) {
          verifyInOrder([
            moveBookmarkUseCase.singleOutput(
              MoveBookmarkUseCaseParam(
                bookmarkId: bookmarks.first.id,
                collectionId: collectionId,
              ),
            ),
          ]);

          verifyNoMoreInteractions(moveBookmarkUseCase);
        },
      );

      blocTest<BookmarksScreenManager, BookmarksScreenState>(
        'WHEN moveBookmark method has been called THEN call the usecase ',
        setUp: () => when(
          moveBookmarkUseCase.singleOutput(
            MoveBookmarkUseCaseParam(
              bookmarkId: bookmarks.first.id,
              collectionId: collectionId,
            ),
          ),
        ).thenAnswer((_) => Future.value(bookmarks.first)),
        build: () => bookmarksScreenManager,
        act: (manager) {
          manager.moveBookmark(
            bookmarkId: bookmarks.first.id,
            collectionId: collectionId,
          );
        },
        verify: (manager) {
          verifyInOrder([
            moveBookmarkUseCase.singleOutput(
              MoveBookmarkUseCaseParam(
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
          removeBookmarkUseCase.singleOutput(
            bookmarks.first.id,
          ),
        ).thenAnswer((_) => Future.value(bookmarks.first)),
        build: () => bookmarksScreenManager,
        act: (manager) {
          manager.removeBookmark(
            bookmarks.first.id,
          );
        },
        verify: (manager) {
          verifyInOrder([
            removeBookmarkUseCase.singleOutput(
              bookmarks.first.id,
            ),
          ]);

          verifyNoMoreInteractions(removeBookmarkUseCase);
        },
      );
    },
  );
}
