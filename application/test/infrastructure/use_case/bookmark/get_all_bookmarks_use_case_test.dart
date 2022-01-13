import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_outputs.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late MockCollectionsRepository collectionsRepository;
  late GetAllBookmarksUseCase getAllBookmarksUseCase;
  final collectionId = UniqueId();
  final Collection collection =
      Collection(id: collectionId, name: 'Test collection', index: 3);

  final bookmark1 = Bookmark(
    id: UniqueId(),
    collectionId: collectionId,
    title: 'Bookmark1 title',
    image: Uint8List.fromList([1, 2, 3]),
    providerName: 'Provider name',
    providerThumbnail: Uint8List.fromList([4, 5, 6]),
    createdAt: DateTime.now().toUtc().toString(),
  );

  final bookmark2 = Bookmark(
    id: UniqueId(),
    collectionId: collectionId,
    title: 'Bookmark2 title',
    image: Uint8List.fromList([1, 2, 3]),
    providerName: 'Provider name',
    providerThumbnail: Uint8List.fromList([4, 5, 6]),
    createdAt: DateTime.now().toUtc().toString(),
  );

  final bookmark3 = Bookmark(
    id: UniqueId(),
    collectionId: UniqueId(),
    title: 'Bookmark3 title',
    image: Uint8List.fromList([1, 2, 3]),
    providerName: 'Provider name',
    providerThumbnail: Uint8List.fromList([4, 5, 6]),
    createdAt: DateTime.now().toUtc().toString(),
  );

  setUp(() {
    bookmarksRepository = MockBookmarksRepository();
    collectionsRepository = MockCollectionsRepository();
    getAllBookmarksUseCase = GetAllBookmarksUseCase(
      bookmarksRepository,
      collectionsRepository,
    );
  });

  group('Get all bookmarks use case', () {
    useCaseTest(
      'WHEN an id of a NOT existing collection has been given THEN yield failure output with proper error enum',
      setUp: () =>
          when(collectionsRepository.getById(collectionId)).thenReturn(null),
      build: () => getAllBookmarksUseCase,
      input: [GetAllBookmarksUseCaseIn(collectionId: collectionId)],
      verify: (_) {
        verify(collectionsRepository.getById(collectionId)).called(1);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseSuccess(
          const BookmarkUseCaseListOut.failure(
            BookmarkUseCaseErrorEnum
                .tryingToGetBookmarksForNotExistingCollection,
          ),
        )
      ],
    );
    useCaseTest(
      'WHEN an id of an existing collection has been given THEN get all the bookmarks of that collection',
      setUp: () {
        when(collectionsRepository.getById(collectionId))
            .thenReturn(collection);
        when(bookmarksRepository.getAll()).thenReturn(
          [bookmark1, bookmark2, bookmark3],
        );
      },
      build: () => getAllBookmarksUseCase,
      input: [const GetAllBookmarksUseCaseIn()],
      verify: (_) {
        verify(bookmarksRepository.getAll()).called(1);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [
        useCaseSuccess(
          BookmarkUseCaseListOut.success(
            [
              bookmark1,
              bookmark2,
              bookmark3,
            ],
          ),
        ),
      ],
    );

    useCaseTest(
      'WHEN called THEN get all the bookmarks by collection id',
      setUp: () {
        when(collectionsRepository.getById(collectionId))
            .thenReturn(collection);
        when(bookmarksRepository.getByCollectionId(collectionId)).thenReturn(
          [bookmark1, bookmark2],
        );
      },
      build: () => getAllBookmarksUseCase,
      input: [GetAllBookmarksUseCaseIn(collectionId: collectionId)],
      verify: (_) {
        verify(bookmarksRepository.getByCollectionId(collectionId)).called(1);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [
        useCaseSuccess(BookmarkUseCaseListOut.success([
          bookmark1,
          bookmark2,
        ])),
      ],
    );
  });
}
