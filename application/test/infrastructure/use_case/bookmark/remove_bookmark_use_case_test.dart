import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_outputs.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late RemoveBookmarkUseCase removeBookmarkUseCase;
  final bookmarkIdToRemove = UniqueId();
  final bookmark = Bookmark(
    id: bookmarkIdToRemove,
    collectionId: UniqueId(),
    title: 'Bookmark1 title',
    image: Uint8List.fromList([1, 2, 3]),
    providerName: 'Provider name',
    providerThumbnail: Uint8List.fromList([4, 5, 6]),
    createdAt: DateTime.now().toUtc().toString(),
  );

  setUp(() {
    bookmarksRepository = MockBookmarksRepository();
    removeBookmarkUseCase = RemoveBookmarkUseCase(bookmarksRepository);
  });

  group(('Remove bookmark use case'), () {
    useCaseTest(
      'WHEN the bookmark to remove doesn\'t exist THEN yield failure output with proper error enum',
      setUp: () => when(bookmarksRepository.getById(bookmarkIdToRemove))
          .thenReturn(null),
      build: () => removeBookmarkUseCase,
      input: [bookmarkIdToRemove],
      verify: (_) {
        verifyInOrder([
          bookmarksRepository.getById(bookmarkIdToRemove),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [
        useCaseSuccess(
          const BookmarkUseCaseGenericOut.failure(
            BookmarkUseCaseErrorEnum.tryingToRemoveNotExistingBookmark,
          ),
        )
      ],
    );

    useCaseTest(
      'WHEN the bookmark to remove exists THEN remove it',
      setUp: () => when(bookmarksRepository.getById(bookmarkIdToRemove))
          .thenReturn(bookmark),
      build: () => removeBookmarkUseCase,
      input: [bookmarkIdToRemove],
      verify: (_) {
        verifyInOrder([
          bookmarksRepository.getById(bookmarkIdToRemove),
          bookmarksRepository.remove(bookmark),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [useCaseSuccess(BookmarkUseCaseGenericOut.success(bookmark))],
    );
  });
}
