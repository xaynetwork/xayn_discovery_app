import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_all_collections_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collections_use_case.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmark_to_collection/manager/move_bookmark_to_collection_manager.dart';
import 'package:xayn_discovery_app/presentation/bottom_sheet/move_bookmark_to_collection/manager/move_bookmark_to_collection_state.dart';

import '../../../test_utils/fakes.dart';
import 'move_bookmark_to_collection_manager_test.mocks.dart';

@GenerateMocks([
  ListenCollectionsUseCase,
  MoveBookmarkUseCase,
  RemoveBookmarkUseCase,
  GetBookmarkUseCase,
  GetAllCollectionsUseCase,
])
void main() {
  group('Move bookmark to collection manager ', () {
    late MockListenCollectionsUseCase listenCollectionsUseCase;
    late MockMoveBookmarkUseCase moveBookmarkUseCase;
    late MockRemoveBookmarkUseCase removeBookmarkUseCase;
    late MockGetBookmarkUseCase getBookmarkUseCase;
    late MockGetAllCollectionsUseCase getAllCollectionsUseCase;

    late MoveBookmarkToCollectionState initialState;
    late MoveBookmarkToCollectionManager moveBookmarkToCollectionManager;

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

    Future<MoveBookmarkToCollectionManager> createManager() async =>
        await MoveBookmarkToCollectionManager.create(
          getAllCollectionsUseCase,
          listenCollectionsUseCase,
          moveBookmarkUseCase,
          removeBookmarkUseCase,
          getBookmarkUseCase,
        );

    setUp(() async {
      listenCollectionsUseCase = MockListenCollectionsUseCase();
      moveBookmarkUseCase = MockMoveBookmarkUseCase();
      removeBookmarkUseCase = MockRemoveBookmarkUseCase();
      getBookmarkUseCase = MockGetBookmarkUseCase();
      getAllCollectionsUseCase = MockGetAllCollectionsUseCase();

      initialState = MoveBookmarkToCollectionState.populated(
        collections: [collection1, collection2],
        selectedCollection: null,
      );

      _mockManagerInitMethodCalls();
      moveBookmarkToCollectionManager = await createManager();
    });

    blocTest<MoveBookmarkToCollectionManager, MoveBookmarkToCollectionState>(
      'WHEN MoveBookmarkToCollectionManager is created THEN get values and emit MoveBookmarkToCollectionStatePopulated ',
      build: () => moveBookmarkToCollectionManager,
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

    blocTest<MoveBookmarkToCollectionManager, MoveBookmarkToCollectionState>(
      'WHEN update Initial Selected Collection method is called AND bookmark is found THEN update selectedCollection state',
      build: () => moveBookmarkToCollectionManager,
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

    blocTest<MoveBookmarkToCollectionManager, MoveBookmarkToCollectionState>(
      'WHEN update Initial Selected Collection method is called AND no bookmark found THEN do not update selectedCollection state',
      build: () => moveBookmarkToCollectionManager,
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

    blocTest<MoveBookmarkToCollectionManager, MoveBookmarkToCollectionState>(
      'WHEN update Initial Selected Collection method is called with forceSelectCollection AND no bookmark found THEN update collection selectedCollection state',
      build: () => moveBookmarkToCollectionManager,
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
        ),
      ],
      verify: (manager) {
        verifyNoMoreInteractions(getBookmarkUseCase);
      },
    );

    blocTest<MoveBookmarkToCollectionManager, MoveBookmarkToCollectionState>(
      'WHEN onApplyPressed is called with selectedCollection != null THEN call MoveBookmarkUseCase ',
      build: () => moveBookmarkToCollectionManager,
      setUp: () {
        when(moveBookmarkUseCase.call(any)).thenAnswer(
          (_) => Future.value([UseCaseResult.success(bookmark)]),
        );
      },
      seed: () => initialState.copyWith(
        selectedCollection: collection2,
      ),
      act: (manager) {
        manager.onApplyPressed(bookmarkId: bookmark.id);
      },
      verify: (manager) {
        verifyInOrder([
          moveBookmarkUseCase.call(any),
        ]);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
      },
    );

    blocTest<MoveBookmarkToCollectionManager, MoveBookmarkToCollectionState>(
      'WHEN onApplyPressed is called with selectedCollection = null THEN call RemoveBookmarkUseCase ',
      build: () => moveBookmarkToCollectionManager,
      setUp: () {
        when(removeBookmarkUseCase.call(any)).thenAnswer(
          (_) => Future.value([UseCaseResult.success(bookmark)]),
        );
      },
      seed: () => initialState.copyWith(
        selectedCollection: null,
      ),
      act: (manager) {
        manager.onApplyPressed(bookmarkId: bookmark.id);
      },
      verify: (manager) {
        verifyInOrder([
          removeBookmarkUseCase.call(any),
        ]);
        verifyNoMoreInteractions(moveBookmarkUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
      },
    );
  });
}
