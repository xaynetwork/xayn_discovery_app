import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_is_bookmarked_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_card/manager/discovery_card_state.dart';

import '../../../test_utils/utils.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late ListenIsBookmarkedUseCase listenIsBookmarkedUseCase;
  final provider = DocumentProvider(
      name: 'Provider name', favicon: 'https://www.foo.com/favicon.ico');
  const url = 'https://url_test.com';

  final bookmark1 = Bookmark(
    id: UniqueId(),
    collectionId: UniqueId(),
    title: 'Bookmark1 title',
    image: Uint8List.fromList([1, 2, 3]),
    provider: provider,
    createdAt: DateTime.now().toUtc().toString(),
    url: url,
  );

  setUp(() {
    bookmarksRepository = MockBookmarksRepository();
    listenIsBookmarkedUseCase = ListenIsBookmarkedUseCase(bookmarksRepository);
  });

  group('Listen isBookmarked use case', () {
    useCaseTest(
      'WHEN a bookmark id is given and repository emits an event THEN usecase emits if that bookmark is bookmarked',
      setUp: () {
        when(bookmarksRepository.watch()).thenAnswer(
          (_) => Stream.value(
            ChangedEvent(
              id: bookmark1.id,
              newObject: bookmark1,
            ),
          ),
        );
        when(bookmarksRepository.getByUrl(bookmark1.url)).thenReturn(bookmark1);
      },
      build: () => listenIsBookmarkedUseCase,
      input: [ListenIsBookmarkUseCaseIn(id: bookmark1.id, url: bookmark1.url)],
      verify: (_) {
        verifyInOrder([
          bookmarksRepository.getByUrl(bookmark1.url),
          bookmarksRepository.watch(),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [useCaseSuccess(BookmarkStatus.bookmarked)],
    );

    useCaseTest(
      'WHEN a bookmark id is given and repository emits an event THEN usecase emits if that bookmark is not bookmarked',
      setUp: () {
        when(bookmarksRepository.watch()).thenAnswer(
          (_) => Stream.value(
            ChangedEvent(
              id: bookmark1.id,
              newObject: bookmark1,
            ),
          ),
        );
        when(bookmarksRepository.getByUrl(bookmark1.url)).thenReturn(null);
      },
      build: () => listenIsBookmarkedUseCase,
      input: [ListenIsBookmarkUseCaseIn(id: bookmark1.id, url: bookmark1.url)],
      verify: (_) {
        verifyInOrder([
          bookmarksRepository.getByUrl(bookmark1.url),
          bookmarksRepository.watch(),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [useCaseSuccess(BookmarkStatus.notBookmarked)],
    );
  });
}
