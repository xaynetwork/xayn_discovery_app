import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/is_bookmarked_use_case.dart';

import '../../../test_utils/fakes.dart';
import '../../../test_utils/utils.dart';

void main() {
  late IsBookmarkedUseCase isBookmarkedUseCase;
  late MockBookmarksRepository bookmarksRepository;

  setUp(() {
    bookmarksRepository = MockBookmarksRepository();
    isBookmarkedUseCase = IsBookmarkedUseCase(bookmarksRepository);
  });

  group('Is Bookmarked use case', () {
    useCaseTest(
      'WHEN bookmark does not exist THEN yield false',
      setUp: () {
        when(bookmarksRepository.getById(fakeBookmark.id)).thenReturn(null);
      },
      build: () => isBookmarkedUseCase,
      input: [fakeBookmark.id],
      verify: (_) {
        verifyInOrder([
          bookmarksRepository.getById(fakeBookmark.id),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [useCaseSuccess(false)],
    );

    useCaseTest(
      'WHEN bookmark exists THEN yield true',
      setUp: () {
        when(bookmarksRepository.getById(fakeBookmark.id))
            .thenReturn(fakeBookmark);
      },
      build: () => isBookmarkedUseCase,
      input: [fakeBookmark.id],
      verify: (_) {
        verifyInOrder([
          bookmarksRepository.getById(fakeBookmark.id),
        ]);
        verifyNoMoreInteractions(bookmarksRepository);
      },
      expect: [useCaseSuccess(true)],
    );
  });
}
