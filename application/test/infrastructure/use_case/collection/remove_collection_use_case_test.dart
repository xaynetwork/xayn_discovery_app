import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/remove_collection_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockCollectionsRepository collectionsRepository;
  late MockBookmarksRepository bookmarksRepository;
  late RemoveCollectionUseCase removeCollectionUseCase;
  final collectionIdToRemove = UniqueId();
  final collection =
      Collection(id: collectionIdToRemove, name: 'Collection name', index: 1);
  final collectionIdMoveBookmarksTo = UniqueId();
  final bookmark1 = Bookmark(
    id: UniqueId(),
    collectionId: collectionIdToRemove,
    title: 'Bookmark1 title',
    image: Uint8List.fromList([1, 2, 3]),
    providerName: 'Provider name',
    providerThumbnail: Uint8List.fromList([4, 5, 6]),
    createdAt: DateTime.now().toUtc().toString(),
  );

  final bookmark2 = Bookmark(
    id: UniqueId(),
    collectionId: collectionIdToRemove,
    title: 'Bookmark2 title',
    image: Uint8List.fromList([1, 2, 3]),
    providerName: 'Provider name',
    providerThumbnail: Uint8List.fromList([4, 5, 6]),
    createdAt: DateTime.now().toUtc().toString(),
  );

  setUp(() {
    collectionsRepository = MockCollectionsRepository();
    bookmarksRepository = MockBookmarksRepository();
    removeCollectionUseCase =
        RemoveCollectionUseCase(collectionsRepository, bookmarksRepository);
  });

  group('Remove collection use case', () {
    useCaseTest(
      'WHEN the collection to remove corresponds to the default collection THEN throw error',
      build: () => removeCollectionUseCase,
      input: [
        RemoveCollectionUseCaseParam(
          collectionIdToRemove: Collection.readLaterId,
        )
      ],
      verify: (_) {
        verifyNoMoreInteractions(collectionsRepository);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [
        useCaseFailure(
          throwsA(
            CollectionUseCaseError.tryingToRemoveDefaultCollection,
          ),
        ),
      ],
    );

    useCaseTest(
      'WHEN the collection to remove doesn\'t exist THEN throw error',
      setUp: () => when(collectionsRepository.getById(any)).thenReturn(null),
      build: () => removeCollectionUseCase,
      input: [
        RemoveCollectionUseCaseParam(collectionIdToRemove: collectionIdToRemove)
      ],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.getById(collectionIdToRemove),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [
        useCaseFailure(
          throwsA(
            CollectionUseCaseError.tryingToRemoveNotExistingCollection,
          ),
        ),
      ],
    );

    useCaseTest(
      'WHEN a collection id for moving bookmarks to has NOT been given THEN delete all bookmarks contained in the collection to remove and then delete the collection',
      setUp: () =>
          when(collectionsRepository.getById(any)).thenReturn(collection),
      build: () => removeCollectionUseCase,
      input: [
        RemoveCollectionUseCaseParam(
          collectionIdToRemove: collectionIdToRemove,
        )
      ],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.getById(collectionIdToRemove),
          bookmarksRepository.removeAllByCollectionId(collectionIdToRemove),
          collectionsRepository.remove(collection),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
        verifyNoMoreInteractions(bookmarksRepository);
      },
    );

    useCaseTest(
      'WHEN a collection id for moving bookmarks has been given THEN move all bookmarks to new collection, delete the collection and return it',
      setUp: () {
        when(collectionsRepository.getById(any)).thenReturn(collection);
        when(bookmarksRepository.getByCollectionId(collectionIdToRemove))
            .thenReturn([bookmark1, bookmark2]);
      },
      build: () => removeCollectionUseCase,
      input: [
        RemoveCollectionUseCaseParam(
          collectionIdToRemove: collectionIdToRemove,
          collectionIdMoveBookmarksTo: collectionIdMoveBookmarksTo,
        )
      ],
      verify: (_) {
        verifyInOrder([
          collectionsRepository.getById(collectionIdToRemove),
          bookmarksRepository.getByCollectionId(collectionIdToRemove),
          bookmarksRepository.save(
            bookmark1.copyWith(collectionId: collectionIdMoveBookmarksTo),
          ),
          bookmarksRepository.save(
            bookmark2.copyWith(collectionId: collectionIdMoveBookmarksTo),
          ),
          collectionsRepository.remove(collection),
        ]);
        verifyNoMoreInteractions(collectionsRepository);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [
        useCaseSuccess(
          collection,
        )
      ],
    );
  });
}
