import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_bookmarks_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late MockCollectionsRepository collectionsRepository;
  late ListenBookmarksUseCase listenBookmarksUseCase;
  final collectionId = UniqueId();

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

  final collection = Collection(
    id: const UniqueId.fromTrustedString('test_collection'),
    name: 'test_collection',
    index: 0,
  );

  setUp(() {
    bookmarksRepository = MockBookmarksRepository();
    collectionsRepository = MockCollectionsRepository();
    listenBookmarksUseCase = ListenBookmarksUseCase(
      bookmarksRepository,
      collectionsRepository,
    );
  });

  group('Listen bookmarks use case', () {
    useCaseTest(
      'WHEN a collection id is given and repository emits an event THEN usecase emits the list of bookmarks for that collection ',
      setUp: () {
        when(bookmarksRepository.watch()).thenAnswer(
          (_) => Stream.value(
            ChangedEvent(
              id: UniqueId(),
              newObject: bookmark1,
            ),
          ),
        );
        when(bookmarksRepository.getByCollectionId(collectionId))
            .thenReturn([bookmark1, bookmark2]);
        when(collectionsRepository.getById(collectionId))
            .thenReturn(collection);
      },
      build: () => listenBookmarksUseCase,
      input: [ListBookmarksUseCaseIn(collectionId: collectionId)],
      verify: (_) {
        verifyInOrder([
          bookmarksRepository.watch(),
          bookmarksRepository.getByCollectionId(collectionId),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [
        useCaseSuccess(
          ListBookmarksUseCaseOut([bookmark1, bookmark2]),
        )
      ],
    );
  });
}
