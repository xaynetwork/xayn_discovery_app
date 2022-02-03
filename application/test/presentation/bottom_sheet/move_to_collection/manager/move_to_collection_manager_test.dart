import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_to_collection/manager/move_to_collection_state.dart';

import '../../../test_utils/fakes.dart';
import 'move_to_collection_manager_test.mocks.dart';

@GenerateMocks([
  ListenCollectionsUseCase,
  MoveBookmarkUseCase,
  RemoveBookmarkUseCase,
  CreateBookmarkFromDocumentUseCase,
  GetBookmarkUseCase,
  GetAllCollectionsUseCase,
])
void main() {
  group('Move document to collection manager ', () {
    late MockListenCollectionsUseCase listenCollectionsUseCase;
    late MockMoveBookmarkUseCase moveBookmarkUseCase;
    late MockRemoveBookmarkUseCase removeBookmarkUseCase;
    late MockCreateBookmarkFromDocumentUseCase
        createBookmarkFromDocumentUseCase;
    late MockGetBookmarkUseCase getBookmarkUseCase;
    late MockGetAllCollectionsUseCase getAllCollectionsUseCase;

    late MoveToCollectionState populatedState;
    late MoveToCollectionManager moveDocumentToCollectionManager;

    final collection1 =
        Collection(id: UniqueId(), name: 'Collection1 name', index: 0);
    final collection2 =
        Collection(id: UniqueId(), name: 'Collection2 name', index: 1);

    final bookmark = fakeBookmark.copyWith(collectionId: collection1.id);

    void _mockManagerInitMethodCalls() {
      when(getAllCollectionsUseCase.singleOutput(none)).thenAnswer(
        (_) => Future.value(
          GetAllCollectionsUseCaseOut(
            [
              collection1,
              collection2,
            ],
          ),
        ),
      );

      when(listenCollectionsUseCase.transform(any)).thenAnswer(
        (_) => const Stream.empty(),
      );

      when(moveBookmarkUseCase.transform(any))
          .thenAnswer((invocation) => invocation.positionalArguments.first);

      when(removeBookmarkUseCase.transform(any))
          .thenAnswer((invocation) => invocation.positionalArguments.first);

      when(createBookmarkFromDocumentUseCase.transform(any))
          .thenAnswer((invocation) => invocation.positionalArguments.first);

      when(removeBookmarkUseCase.transaction(any))
          .thenAnswer((_) => Stream.value(fakeBookmark));

      when(moveBookmarkUseCase.transaction(any))
          .thenAnswer((_) => Stream.value(fakeBookmark));

      when(createBookmarkFromDocumentUseCase.transaction(any))
          .thenAnswer((_) => Stream.value(fakeBookmark));
    }

    Future<MoveToCollectionManager> createManager() async =>
        await MoveToCollectionManager.create(
          getAllCollectionsUseCase,
          listenCollectionsUseCase,
          moveBookmarkUseCase,
          removeBookmarkUseCase,
          getBookmarkUseCase,
          createBookmarkFromDocumentUseCase,
        );

    setUp(() async {
      listenCollectionsUseCase = MockListenCollectionsUseCase();
      moveBookmarkUseCase = MockMoveBookmarkUseCase();
      removeBookmarkUseCase = MockRemoveBookmarkUseCase();
      createBookmarkFromDocumentUseCase =
          MockCreateBookmarkFromDocumentUseCase();
      getBookmarkUseCase = MockGetBookmarkUseCase();
      getAllCollectionsUseCase = MockGetAllCollectionsUseCase();

      populatedState = MoveToCollectionState.populated(
        collections: [collection1, collection2],
        selectedCollection: null,
        isBookmarked: false,
        shouldClose: false,
      );

      _mockManagerInitMethodCalls();
      moveDocumentToCollectionManager = await createManager();
    });

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN MoveDocumentToCollectionManager is created THEN get values and emit MoveDocumentToCollectionStatePopulated ',
      build: () => moveDocumentToCollectionManager,
      expect: () => [
        populatedState,
      ],
      verify: (manager) {
        verifyInOrder([
          getAllCollectionsUseCase.singleOutput(none),
          listenCollectionsUseCase.transform(any),
        ]);
        verifyNoMoreInteractions(getAllCollectionsUseCase);
        verifyNoMoreInteractions(listenCollectionsUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN update Initial Selected Collection method is called AND bookmark is found THEN update isBookmarked state',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(getBookmarkUseCase.singleOutput(bookmark.id)).thenAnswer(
          (_) => Future.value(bookmark),
        );
      },
      act: (manager) {
        manager.updateInitialSelectedCollection(bookmarkId: bookmark.id);
      },
      expect: () => [
        populatedState,
        populatedState.copyWith(
          isBookmarked: true,
          selectedCollection: collection1,
        )
      ],
      verify: (manager) {
        verifyInOrder([
          getBookmarkUseCase.singleOutput(bookmark.id),
        ]);
        verifyNoMoreInteractions(getBookmarkUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN update Initial Selected Collection method is called AND no bookmark found THEN do not update isBookmarked state',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(getBookmarkUseCase.singleOutput(bookmark.id)).thenAnswer(
          (_) => throw BookmarkUseCaseError.tryingToGetNotExistingBookmark,
        );
      },
      act: (manager) {
        manager.updateInitialSelectedCollection(bookmarkId: bookmark.id);
      },
      expect: () => [populatedState],
      verify: (manager) {
        verifyInOrder([
          getBookmarkUseCase.singleOutput(bookmark.id),
        ]);
        verifyNoMoreInteractions(getBookmarkUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN update Initial Selected Collection method is called with forceSelectCollection AND no bookmark found THEN update collection state with false isBookmarked',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(getBookmarkUseCase.singleOutput(bookmark.id)).thenAnswer(
          (_) => throw BookmarkUseCaseError.tryingToGetNotExistingBookmark,
        );
      },
      act: (manager) {
        manager.updateInitialSelectedCollection(
          bookmarkId: bookmark.id,
          forceSelectCollection: collection2,
        );
      },
      expect: () => [
        populatedState,
        populatedState.copyWith(
          selectedCollection: collection2,
          isBookmarked: false,
        ),
      ],
      verify: (manager) {
        verifyInOrder([
          getBookmarkUseCase.singleOutput(bookmark.id),
        ]);
        verifyNoMoreInteractions(getBookmarkUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN update Initial Selected Collection method is called with forceSelectCollection AND bookmark is found THEN update collection state with true isBookmarked',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(getBookmarkUseCase.singleOutput(bookmark.id)).thenAnswer(
          (_) => Future.value(bookmark),
        );
      },
      act: (manager) {
        manager.updateInitialSelectedCollection(
          bookmarkId: bookmark.id,
          forceSelectCollection: collection2,
        );
      },
      expect: () => [
        populatedState,
        populatedState.copyWith(
          selectedCollection: collection2,
          isBookmarked: true,
        ),
      ],
      verify: (manager) {
        verifyInOrder([
          getBookmarkUseCase.singleOutput(bookmark.id),
        ]);
        verifyNoMoreInteractions(getBookmarkUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = false and selectedCollection != null THEN call CreateBookmarkFromDocumentUseCase ',
      build: () => moveDocumentToCollectionManager,
      seed: () => populatedState.copyWith(
        selectedCollection: collection2,
        isBookmarked: false,
      ),
      act: (manager) {
        manager.onApplyToDocumentPressed(document: fakeDocument);
      },
      verify: (manager) {
        verifyInOrder([
          createBookmarkFromDocumentUseCase.transform(any),
          moveBookmarkUseCase.transform(any),
          removeBookmarkUseCase.transform(any),
          createBookmarkFromDocumentUseCase.transaction(any),
        ]);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = true and selectedCollection != null THEN call MoveBookmarkUseCase ',
      build: () => moveDocumentToCollectionManager,
      seed: () => populatedState.copyWith(
        selectedCollection: collection2,
        isBookmarked: true,
      ),
      act: (manager) {
        manager.onApplyToDocumentPressed(document: fakeDocument);
      },
      verify: (manager) {
        verifyInOrder([
          createBookmarkFromDocumentUseCase.transform(any),
          moveBookmarkUseCase.transform(any),
          removeBookmarkUseCase.transform(any),
          moveBookmarkUseCase.transaction(any),
        ]);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = true and selectedCollection = null THEN call RemoveBookmarkUseCase ',
      build: () => moveDocumentToCollectionManager,
      seed: () => populatedState.copyWith(
        selectedCollection: null,
        isBookmarked: true,
      ),
      act: (manager) {
        manager.onApplyToDocumentPressed(document: fakeDocument);
      },
      verify: (manager) {
        verifyInOrder([
          createBookmarkFromDocumentUseCase.transform(any),
          moveBookmarkUseCase.transform(any),
          removeBookmarkUseCase.transform(any),
          removeBookmarkUseCase.transaction(any),
        ]);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
      },
    );

    blocTest<MoveToCollectionManager, MoveToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = false and selectedCollection = null THEN do not expect calls ',
      build: () => moveDocumentToCollectionManager,
      seed: () => populatedState.copyWith(
        selectedCollection: null,
        isBookmarked: false,
      ),
      act: (manager) {
        manager.onApplyToDocumentPressed(document: fakeDocument);
      },
      expect: () => [],
      verify: (manager) {
        verifyInOrder([
          createBookmarkFromDocumentUseCase.transform(any),
          moveBookmarkUseCase.transform(any),
          removeBookmarkUseCase.transform(any),
        ]);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
      },
    );
  });
}
