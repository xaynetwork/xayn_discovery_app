import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/concepts/use_case/test/use_case_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/repository_event.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/listen_is_bookmarked_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late ListenIsBookmarkedUseCase listenIsBookmarkedUseCase;
  final bookmark1 = Bookmark(
    id: UniqueId(),
    collectionId: UniqueId(),
    title: 'Bookmark1 title',
    image: Uint8List.fromList([1, 2, 3]),
    providerName: 'Provider name',
    providerThumbnail: Uint8List.fromList([4, 5, 6]),
    createdAt: DateTime.now().toUtc().toString(),
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
        when(bookmarksRepository.getById(bookmark1.id)).thenReturn(bookmark1);
      },
      build: () => listenIsBookmarkedUseCase,
      input: [bookmark1.id],
      verify: (_) {
        verifyInOrder([
          bookmarksRepository.watch(),
          bookmarksRepository.getById(bookmark1.id),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [useCaseSuccess(true)],
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
        when(bookmarksRepository.getById(bookmark1.id)).thenReturn(null);
      },
      build: () => listenIsBookmarkedUseCase,
      input: [bookmark1.id],
      verify: (_) {
        verifyInOrder([
          bookmarksRepository.watch(),
          bookmarksRepository.getById(bookmark1.id),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [useCaseSuccess(false)],
    );
  });
}
