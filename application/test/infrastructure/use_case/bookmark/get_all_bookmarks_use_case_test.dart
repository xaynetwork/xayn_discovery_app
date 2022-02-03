import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late MockCollectionsRepository collectionsRepository;
  late GetAllBookmarksUseCase getAllBookmarksUseCase;
  final collectionId = UniqueId();
  final Collection collection =
      Collection(id: collectionId, name: 'Test collection', index: 3);
  final provider = DocumentProvider(
    name: 'Provider name',
    favicon: 'https://www.foo.com/favicon.ico',
  );

  final bookmark1 = Bookmark(
    id: UniqueId(),
    collectionId: collectionId,
    title: 'Bookmark1 title',
    image: Uint8List.fromList([1, 2, 3]),
    provider: provider,
    createdAt: DateTime.now().toUtc().toString(),
  );

  final bookmark2 = Bookmark(
    id: UniqueId(),
    collectionId: collectionId,
    title: 'Bookmark2 title',
    image: Uint8List.fromList([1, 2, 3]),
    provider: provider,
    createdAt: DateTime.now().toUtc().toString(),
  );

  final bookmark3 = Bookmark(
    id: UniqueId(),
    collectionId: UniqueId(),
    title: 'Bookmark3 title',
    image: Uint8List.fromList([1, 2, 3]),
    provider: provider,
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
      'WHEN an id of a NOT existing collection has been given THEN throw error',
      setUp: () =>
          when(collectionsRepository.getById(collectionId)).thenReturn(null),
      build: () => getAllBookmarksUseCase,
      input: [GetAllBookmarksUseCaseIn(collectionId: collectionId)],
      verify: (_) {
        verify(collectionsRepository.getById(collectionId)).called(1);
        verifyNoMoreInteractions(collectionsRepository);
      },
      expect: [
        useCaseFailure(
          throwsA(
            BookmarkUseCaseError.tryingToGetBookmarksForNotExistingCollection,
          ),
        ),
      ],
    );
    useCaseTest(
      'WHEN no collection id has been provided THEN get all the bookmarks ',
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
          GetAllBookmarksUseCaseOut(
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
      'WHEN called with an existing collection id THEN get all the bookmarks by collection id',
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
        useCaseSuccess(
          GetAllBookmarksUseCaseOut(
            [
              bookmark1,
              bookmark2,
            ],
          ),
        ),
      ],
    );
  });
}
