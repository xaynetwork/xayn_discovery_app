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
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_document_to_collection/manager/move_document_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_document_to_collection/manager/move_document_to_collection_state.dart';

import '../../../test_utils/fakes.dart';
import 'move_document_to_collection_manager_test.mocks.dart';

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

    late MoveDocumentToCollectionState initialState;
    late MoveDocumentToCollectionManager moveDocumentToCollectionManager;

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
    }

    Future<MoveDocumentToCollectionManager> createManager() async =>
        await MoveDocumentToCollectionManager.create(
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

      initialState = MoveDocumentToCollectionState.populated(
        collections: [collection1, collection2],
        selectedCollection: null,
        isBookmarked: false,
      );

      _mockManagerInitMethodCalls();
      moveDocumentToCollectionManager = await createManager();
    });

    blocTest<MoveDocumentToCollectionManager, MoveDocumentToCollectionState>(
      'WHEN MoveDocumentToCollectionManager is created THEN get values and emit MoveDocumentToCollectionStatePopulated ',
      build: () => moveDocumentToCollectionManager,
      expect: () => [
        initialState,
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

    blocTest<MoveDocumentToCollectionManager, MoveDocumentToCollectionState>(
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
        initialState,
        initialState.copyWith(
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

    blocTest<MoveDocumentToCollectionManager, MoveDocumentToCollectionState>(
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
      expect: () => [initialState],
      verify: (manager) {
        verifyInOrder([
          getBookmarkUseCase.singleOutput(bookmark.id),
        ]);
        verifyNoMoreInteractions(getBookmarkUseCase);
      },
    );

    blocTest<MoveDocumentToCollectionManager, MoveDocumentToCollectionState>(
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
        initialState,
        initialState.copyWith(
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

    blocTest<MoveDocumentToCollectionManager, MoveDocumentToCollectionState>(
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
        initialState,
        initialState.copyWith(
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

    blocTest<MoveDocumentToCollectionManager, MoveDocumentToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = false and selectedCollection != null THEN call CreateBookmarkFromDocumentUseCase ',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(createBookmarkFromDocumentUseCase.call(any)).thenAnswer(
          (_) => Future.value([UseCaseResult.success(bookmark)]),
        );
      },
      seed: () => initialState.copyWith(
        selectedCollection: collection2,
        isBookmarked: false,
      ),
      act: (manager) {
        manager.onApplyPressed(document: fakeDocument);
      },
      verify: (manager) {
        verifyInOrder([
          createBookmarkFromDocumentUseCase.call(any),
        ]);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
      },
    );

    blocTest<MoveDocumentToCollectionManager, MoveDocumentToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = true and selectedCollection != null THEN call MoveBookmarkUseCase ',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(moveBookmarkUseCase.call(any)).thenAnswer(
          (_) => Future.value([UseCaseResult.success(bookmark)]),
        );
      },
      seed: () => initialState.copyWith(
        selectedCollection: collection2,
        isBookmarked: true,
      ),
      act: (manager) {
        manager.onApplyPressed(document: fakeDocument);
      },
      verify: (manager) {
        verifyInOrder([
          moveBookmarkUseCase.call(any),
        ]);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
      },
    );

    blocTest<MoveDocumentToCollectionManager, MoveDocumentToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = true and selectedCollection = null THEN call RemoveBookmarkUseCase ',
      build: () => moveDocumentToCollectionManager,
      setUp: () {
        when(removeBookmarkUseCase.call(any)).thenAnswer(
          (_) => Future.value([UseCaseResult.success(bookmark)]),
        );
      },
      seed: () => initialState.copyWith(
        selectedCollection: null,
        isBookmarked: true,
      ),
      act: (manager) {
        manager.onApplyPressed(document: fakeDocument);
      },
      verify: (manager) {
        verifyInOrder([
          removeBookmarkUseCase.call(any),
        ]);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
      },
    );

    blocTest<MoveDocumentToCollectionManager, MoveDocumentToCollectionState>(
      'WHEN onApplyPressed is called with isBookmarked = false and selectedCollection = null THEN do not expect calls ',
      build: () => moveDocumentToCollectionManager,
      seed: () => initialState.copyWith(
        selectedCollection: null,
        isBookmarked: false,
      ),
      act: (manager) {
        manager.onApplyPressed(document: fakeDocument);
      },
      expect: () => [],
      verify: (manager) {
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
      },
    );
  });
}
