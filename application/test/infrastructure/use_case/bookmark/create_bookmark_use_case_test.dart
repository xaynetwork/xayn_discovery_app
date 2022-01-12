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
    dateTimeHandler = MockDateTimeHandler();
    createBookmarkUseCase = CreateBookmarkUseCase(
      bookmarksRepository,
      dateTimeHandler,
    );
  });

  group('Create Bookmark use case', () {
    useCaseTest(
      'WHEN input values are given THEN create the bookmark and save it',
      setUp: () {
        when(dateTimeHandler.getDateTimeNow()).thenReturn(dateTime);
      },
      build: () => createBookmarkUseCase,
      input: [
        CreateBookmarkUseCaseParam(
          id: bookmarkId,
          collectionId: collectionId,
          title: title,
          image: image,
          providerName: providerName,
          providerThumbnail: providerThumbnail,
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
