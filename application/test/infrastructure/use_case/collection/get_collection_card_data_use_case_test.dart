import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/get_collection_card_data_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late MockCollectionsRepository collectionsRepository;
  late GetCollectionCardDataUseCase getCollectionCardDataUseCase;
  final UniqueId collectionId = UniqueId();
  final Collection collection = Collection(
    id: UniqueId(),
    index: 2,
    name: 'Collection Test',
  );

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
    bookmarksRepository = MockBookmarksRepository();
    collectionsRepository = MockCollectionsRepository();
    getCollectionCardDataUseCase = GetCollectionCardDataUseCase(
      bookmarksRepository,
      collectionsRepository,
    );
  });

  group(
    'Get collection card data use case',
    () {
      useCaseTest(
        'WHEN the collection to retrieve data for doesn\'t exist THEN throw error',
        setUp: () =>
            when(collectionsRepository.getById(collectionId)).thenReturn(null),
        build: () => getCollectionCardDataUseCase,
        input: [collectionId],
        verify: (_) {
          verifyInOrder([
            collectionsRepository.getById(collectionId),
          ]);
          verifyNoMoreInteractions(collectionsRepository);
          verifyNoMoreInteractions(bookmarksRepository);
        },
        expect: [
          useCaseFailure(
            throwsA(
              CollectionUseCaseError
                  .tryingToGetCardDataForNotExistingCollection,
            ),
          ),
        ],
      );

      useCaseTest(
        'WHEN the id of an existing collection has been given THEN retrieve the card data for it',
        setUp: () {
          when(collectionsRepository.getById(collectionId))
              .thenReturn(collection);
          when(bookmarksRepository.getByCollectionId(collectionId))
              .thenReturn(bookmarks);
        },
        build: () => getCollectionCardDataUseCase,
        input: [collectionId],
        verify: (_) {
          verifyInOrder([
            collectionsRepository.getById(collectionId),
            bookmarksRepository.getByCollectionId(collectionId),
          ]);
          verifyNoMoreInteractions(collectionsRepository);
          verifyNoMoreInteractions(bookmarksRepository);
        },
        expect: [
          useCaseSuccess(
            GetCollectionCardDataUseCaseOut(
              numOfItems: bookmarks.length,
              image: bookmarks.last.image,
            ),
          )
        ],
      );
    },
  );
}
