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
    listenBookmarksUseCase = MockListenBookmarksUseCase();
    removeBookmarkUseCase = MockRemoveBookmarkUseCase();
    moveBookmarkUseCase = MockMoveBookmarkUseCase();
    dateTimeHandler = MockDateTimeHandler();

    when(listenBookmarksUseCase.transform(any))
        .thenAnswer((invocation) => invocation.positionalArguments.first);

    when(listenBookmarksUseCase.transaction(any)).thenAnswer(
      (_) => Stream.value(ListBookmarksUseCaseOut(bookmarks)),
    );

    bookmarksScreenManager = BookmarksScreenManager(
      listenBookmarksUseCase,
      removeBookmarkUseCase,
      moveBookmarkUseCase,
      dateTimeHandler,
    );
    initialState = BookmarksScreenState.initial();
    populatedState = BookmarksScreenState.populated(bookmarks, timestamp);

    when(dateTimeHandler.getDateTimeNow()).thenReturn(timestamp);
  });

  group('Bookmarks screen manager', () {
    blocTest<BookmarksScreenManager, BookmarksScreenState>(
      'WHEN manager is created THEN emit initial state ',
      setUp: () => when(dateTimeHandler.getDateTimeNow()).thenReturn(timestamp),
      build: () => bookmarksScreenManager,
      verify: (manager) => expect(manager.state.bookmarks.isEmpty, true),
      expect: () => [],
    );

    blocTest<BookmarksScreenManager, BookmarksScreenState>(
      'WHEN enteringScreen method has been called THEN emit call the usecase and emit populate state ',
      setUp: () {},
      build: () => bookmarksScreenManager,
      act: (manager) {
        manager.enteringScreen(collectionId);
      },
      verify: (manager) {
        verifyInOrder([
          listenBookmarksUseCase
              .transaction(ListBookmarksUseCaseIn(collectionId: collectionId)),
          // listenBookmarksUseCase.transform(Stream.value(collectionId)),
        ]);
        verifyNoMoreInteractions(listenBookmarksUseCase);
        // verifyNoMoreInteractions(listenBookmarksUseCase);
      },
      expect: () => [initialState],
    );
  });
}
