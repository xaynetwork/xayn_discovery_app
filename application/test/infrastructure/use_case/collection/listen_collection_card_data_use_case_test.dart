import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/collection_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/collection/listen_collection_card_data_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late MockCollectionsRepository collectionsRepository;
  late ListenCollectionCardDataUseCase getCollectionCardDataUseCase;
  final UniqueId collectionId = UniqueId();
  final Collection collection = Collection(
    id: UniqueId(),
    index: 2,
    name: 'Collection Test',
  );
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
    bookmarksRepository = MockBookmarksRepository();
    collectionsRepository = MockCollectionsRepository();
    getCollectionCardDataUseCase = ListenCollectionCardDataUseCase(
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
          when(bookmarksRepository.watch())
              .thenAnswer((realInvocation) => const Stream.empty());
        },
        build: () => getCollectionCardDataUseCase,
        input: [collectionId],
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
