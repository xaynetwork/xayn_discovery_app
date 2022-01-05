import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_all_bookmarks_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late GetAllBookmarksUseCase getAllBookmarksUseCase;
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
    getAllBookmarksUseCase = GetAllBookmarksUseCase(bookmarksRepository);
  });

  group('Get all bookmarks use case', () {
    useCaseTest(
      'WHEN called THEN get all the bookmarks',
      setUp: () => when(bookmarksRepository.getAll()).thenReturn(
        [bookmark1, bookmark2, bookmark3],
      ),
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
      'WHEN called THEN get all the bookmarks by collection id',
      setUp: () =>
          when(bookmarksRepository.getByCollectionId(collectionId)).thenReturn(
        [bookmark1, bookmark2],
      ),
      build: () => getAllBookmarksUseCase,
      input: [GetAllBookmarksUseCaseIn(collectionId: collectionId)],
      verify: (_) {
        verify(bookmarksRepository.getByCollectionId(collectionId)).called(1);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [
        useCaseSuccess(GetAllBookmarksUseCaseOut([
          bookmark1,
          bookmark2,
        ])),
      ],
    );
  });
}
