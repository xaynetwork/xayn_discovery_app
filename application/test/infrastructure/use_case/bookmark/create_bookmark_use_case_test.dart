import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late MockDateTimeHandler dateTimeHandler;
  late CreateBookmarkUseCase createBookmarkUseCase;

  final bookmarkId = UniqueId();
  final dateTime = DateTime.now();
  final collectionId = UniqueId();
  const title = 'Bookmark title';
  final image = Uint8List.fromList([1, 2, 3]);
  final provider = DocumentProvider(
    name: 'Provider name',
    favicon: 'https://www.foo.com/favicon.ico',
  );

  final createdBookmark = Bookmark(
    id: bookmarkId,
    collectionId: collectionId,
    title: title,
    image: image,
    provider: provider,
    createdAt: dateTime.toUtc().toString(),
  );

  setUp(() {
    bookmarksRepository = MockBookmarksRepository();
    dateTimeHandler = MockDateTimeHandler();
    createBookmarkUseCase = CreateBookmarkUseCase(
      bookmarksRepository,
      dateTimeHandler,
    );
  });

  group('Create Bookmark use case', () {
    useCaseTest(
      'WHEN input values are given THEN create bookmark, save it and yield bookmark',
      setUp: () {
        when(dateTimeHandler.getDateTimeNow()).thenReturn(dateTime);
      },
      build: () => createBookmarkUseCase,
      input: [
        CreateBookmarkUseCaseIn(
          id: bookmarkId,
          collectionId: collectionId,
          title: title,
          image: image,
          provider: provider,
        )
      ],
      verify: (_) {
        verifyInOrder([
          dateTimeHandler.getDateTimeNow(),
          bookmarksRepository.save(createdBookmark),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [useCaseSuccess(createdBookmark)],
    );
  });
}
