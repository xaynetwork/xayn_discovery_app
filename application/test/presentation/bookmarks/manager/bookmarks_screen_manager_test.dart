import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_exception.dart';
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
  late MockGetAllBookmarksUseCase getAllBookmarksUseCase;
  late MockListenBookmarksUseCase listenBookmarksUseCase;
  late MockRemoveBookmarkUseCase removeBookmarkUseCase;
  late MockMoveBookmarkUseCase moveBookmarkUseCase;
  late MockDateTimeHandler dateTimeHandler;
  late BookmarksScreenManager bookmarksScreenManager;
  late BookmarksScreenState initialState;
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
    getAllBookmarksUseCase = MockGetAllBookmarksUseCase();
    listenBookmarksUseCase = MockListenBookmarksUseCase();
    removeBookmarkUseCase = MockRemoveBookmarkUseCase();
    moveBookmarkUseCase = MockMoveBookmarkUseCase();
    dateTimeHandler = MockDateTimeHandler();
    bookmarksScreenManager = BookmarksScreenManager(
      getAllBookmarksUseCase,
      listenBookmarksUseCase,
      removeBookmarkUseCase,
      moveBookmarkUseCase,
      dateTimeHandler,
    );
    initialState = BookmarksScreenState.initial();
    populatedState = BookmarksScreenState.populated(bookmarks, timestamp);

    when(listenBookmarksUseCase.transform(any)).thenAnswer(
      (_) => Stream.value(collectionId),
    );

    when(dateTimeHandler.getDateTimeNow()).thenReturn(timestamp);
  });

  group('Bookmarks screen manager', () {
    blocTest<BookmarksScreenManager, BookmarksScreenState>(
      'WHEN manager is created THEN emit initial state ',
      setUp: () => when(dateTimeHandler.getDateTimeNow()).thenReturn(timestamp),
      build: () => bookmarksScreenManager,
      expect: () => [
        initialState,
      ],
    );

    blocTest<BookmarksScreenManager, BookmarksScreenState>(
      'WHEN enteringScreen method has been called THEN emit call the usecase and emit populate state ',
      setUp: () {
        when(getAllBookmarksUseCase.singleOutput(
                GetAllBookmarksUseCaseIn(collectionId: collectionId)))
            .thenAnswer((_) => Future.error(BookmarkUseCaseException(
                errorMessageGettingBookmarksOfNotExistingCollection)));
      },
      build: () => bookmarksScreenManager,
      act: (manager) {
        manager.enteringScreen(collectionId);
        manager.updateBookmarksList(collectionId);
      },
      verify: (manager) {
        verifyInOrder([
          getAllBookmarksUseCase.singleOutput(
              GetAllBookmarksUseCaseIn(collectionId: collectionId)),
          // listenBookmarksUseCase.transform(Stream.value(collectionId)),
        ]);
        verifyNoMoreInteractions(getAllBookmarksUseCase);
        // verifyNoMoreInteractions(listenBookmarksUseCase);
      },
      expect: () => [
        initialState,
        initialState.copyWith(
          errorMsg: errorMessageGettingBookmarksOfNotExistingCollection,
        )
      ],
    );
  });
}
