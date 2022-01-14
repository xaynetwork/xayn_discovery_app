import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';

import '../use_case_mocks/use_case_mocks.mocks.dart';

void main() {
  late MockBookmarksRepository bookmarksRepository;
  late MockUniqueIdHandler uniqueIdHandler;
  late MockDateTimeHandler dateTimeHandler;
  late CreateBookmarkUseCase createBookmarkUseCase;

  final bookmarkId = UniqueId();
  final dateTime = DateTime.now();
  final collectionId = UniqueId();
  const title = 'Bookmark title';
  final image = Uint8List.fromList([1, 2, 3]);
  const providerName = 'Provider name';
  final providerThumbnail = Uint8List.fromList([4, 5, 6]);

  final createdBookmark = Bookmark(
    id: bookmarkId,
    collectionId: collectionId,
    title: title,
    image: image,
    providerName: providerName,
    providerThumbnail: providerThumbnail,
    createdAt: dateTime.toUtc().toString(),
  );

  setUp(() {
    bookmarksRepository = MockBookmarksRepository();
    uniqueIdHandler = MockUniqueIdHandler();
    dateTimeHandler = MockDateTimeHandler();
    createBookmarkUseCase = CreateBookmarkUseCase(
      bookmarksRepository,
      uniqueIdHandler,
      dateTimeHandler,
    );
  });

  group('Create Bookmark use case', () {
    useCaseTest(
      'WHEN input values are given THEN create bookmark, save it and yield bookmark',
      setUp: () {
        when(uniqueIdHandler.generateUniqueId()).thenReturn(bookmarkId);
        when(dateTimeHandler.getDateTimeNow()).thenReturn(dateTime);
      },
      build: () => createBookmarkUseCase,
      input: [
        CreateBookmarkUseCaseIn(
          collectionId: collectionId,
          title: title,
          image: image,
          providerName: providerName,
          providerThumbnail: providerThumbnail,
        )
      ],
      verify: (_) {
        verifyInOrder([
          uniqueIdHandler.generateUniqueId(),
          bookmarksRepository.save(createdBookmark),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [useCaseSuccess(createdBookmark)],
    );
  });
}
