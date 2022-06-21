import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late RemoveBookmarkUseCase removeBookmarkUseCase;
  final bookmarkIdToRemove = UniqueId();
  const bookmarkUrlToRemove = 'https://url_to_remove.com';
  final provider = DocumentProvider(
      name: 'Provider name', favicon: 'https://www.foo.com/favicon.ico');
  const url = 'https://url_test.com';

  final bookmark = Bookmark(
    id: bookmarkIdToRemove,
    collectionId: UniqueId(),
    title: 'Bookmark1 title',
    image: Uint8List.fromList([1, 2, 3]),
    provider: provider,
    createdAt: DateTime.now().toUtc().toString(),
    uri: Uri.parse(url),
  );

  setUp(() {
    bookmarksRepository = MockBookmarksRepository();
    final documentRepository = MockDocumentRepository();
    when(documentRepository.getById(any)).thenReturn(null);
    removeBookmarkUseCase = RemoveBookmarkUseCase(
      bookmarksRepository,
      documentRepository,
    );
  });

  group(('Remove bookmark use case'), () {
    useCaseTest(
      'WHEN the bookmark to remove doesn\'t exist THEN throw error',
      setUp: () => when(bookmarksRepository.getByUrl(bookmarkUrlToRemove))
          .thenReturn(null),
      build: () => removeBookmarkUseCase,
      input: [bookmarkUrlToRemove],
      verify: (_) {
        verifyInOrder([
          bookmarksRepository.getByUrl(bookmarkUrlToRemove),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [
        useCaseFailure(
          throwsA(BookmarkUseCaseError.tryingToRemoveNotExistingBookmark),
        ),
      ],
    );

    useCaseTest(
      'WHEN the bookmark to remove exists THEN remove it',
      setUp: () => when(bookmarksRepository.getByUrl(bookmarkUrlToRemove))
          .thenReturn(bookmark),
      build: () => removeBookmarkUseCase,
      input: [bookmarkUrlToRemove],
      verify: (_) {
        verifyInOrder([
          bookmarksRepository.getByUrl(bookmarkUrlToRemove),
          bookmarksRepository.remove(bookmark),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [useCaseSuccess(bookmark)],
    );
  });
}
