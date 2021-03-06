import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/move_bookmark_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late MockCollectionsRepository collectionsRepository;
  late MoveBookmarkUseCase moveBookmarkUseCase;
  const bookamarkUrlToMove = 'https://url_bookmark_to_move.com';
  final collectionIdWhereToMoveBookmark = UniqueId();
  final input = MoveBookmarkUseCaseIn(
    bookmarkId: Bookmark.generateUniqueIdFromUri(Uri.parse(bookamarkUrlToMove)),
    collectionId: collectionIdWhereToMoveBookmark,
  );
  final provider = DocumentProvider(
      name: 'Provider name', favicon: 'https://www.foo.com/favicon.ico');
  const url = 'https://url_test.com';

  final bookmark = Bookmark(
    documentId: UniqueId(),
    collectionId: UniqueId(),
    title: 'Bookmark1 title',
    image: Uint8List.fromList([1, 2, 3]),
    provider: provider,
    createdAt: DateTime.now().toUtc().toString(),
    uri: Uri.parse(url),
  );

  final collection = Collection(
    id: collectionIdWhereToMoveBookmark,
    name: 'Collection name',
    index: 1,
  );

  final updatedBookmark = bookmark.copyWith(
    collectionId: input.collectionId,
  );

  setUp(() {
    bookmarksRepository = MockBookmarksRepository();
    collectionsRepository = MockCollectionsRepository();
    moveBookmarkUseCase =
        MoveBookmarkUseCase(bookmarksRepository, collectionsRepository);
  });

  group(
    'Move bookmark use case',
    () {
      useCaseTest(
        'WHEN the bookmark to move doesn\'t exist THEN throw error',
        setUp: () => when(bookmarksRepository.getById(any)).thenReturn(null),
        build: () => moveBookmarkUseCase,
        input: [input],
        verify: (_) {
          verifyInOrder(
            [
              bookmarksRepository.getById(any),
            ],
          );
          verifyNoMoreInteractions(bookmarksRepository);
          verifyNoMoreInteractions(collectionsRepository);
        },
        expect: [
          useCaseFailure(
            throwsA(BookmarkUseCaseError.tryingToMoveNotExistingBookmark),
          )
        ],
      );

      useCaseTest(
        'WHEN the collection where to move the bookmark to doesn\'t exist THEN throw error',
        setUp: () {
          when(bookmarksRepository.getById(any)).thenReturn(bookmark);
          when(collectionsRepository.getById(any)).thenReturn(null);
        },
        build: () => moveBookmarkUseCase,
        input: [input],
        verify: (_) {
          verifyInOrder(
            [
              bookmarksRepository.getById(any),
              collectionsRepository.getById(any),
            ],
          );
          verifyNoMoreInteractions(bookmarksRepository);
          verifyNoMoreInteractions(collectionsRepository);
        },
        expect: [
          useCaseFailure(
            throwsA(BookmarkUseCaseError
                .tryingToMoveBookmarkToNotExistingCollection),
          ),
        ],
      );
      useCaseTest(
          'WHEN bookmark id to move and new collection id are given THEN move the bookmark',
          setUp: () {
            when(bookmarksRepository.getById(any)).thenReturn(bookmark);
            when(collectionsRepository.getById(any)).thenReturn(collection);
          },
          build: () => moveBookmarkUseCase,
          input: [input],
          verify: (_) {
            verifyInOrder(
              [
                bookmarksRepository.getById(any),
                collectionsRepository.getById(any),
                bookmarksRepository.save(updatedBookmark),
              ],
            );
            verifyNoMoreInteractions(bookmarksRepository);
            verifyNoMoreInteractions(collectionsRepository);
          },
          expect: [useCaseSuccess(updatedBookmark)]);
    },
  );
}
