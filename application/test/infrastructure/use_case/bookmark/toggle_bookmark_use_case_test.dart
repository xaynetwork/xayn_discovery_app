import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture_test.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/toggle_bookmark_use_case.dart';

import '../../../test_utils/fakes.dart';
import '../../../test_utils/utils.dart';

void main() {
  late ToggleBookmarkUseCase toggleBookmarkUseCase;
  late MockIsBookmarkedUseCase isBookmarkedUseCase;
  late MockCreateBookmarkFromDocumentUseCase createBookmarkFromDocumentUseCase;
  late MockRemoveBookmarkUseCase removeBookmarkUseCase;

  setUp(() {
    isBookmarkedUseCase = MockIsBookmarkedUseCase();
    createBookmarkFromDocumentUseCase = MockCreateBookmarkFromDocumentUseCase();
    removeBookmarkUseCase = MockRemoveBookmarkUseCase();
    toggleBookmarkUseCase = ToggleBookmarkUseCase(
      isBookmarkedUseCase,
      createBookmarkFromDocumentUseCase,
      removeBookmarkUseCase,
    );
    when(createBookmarkFromDocumentUseCase.singleOutput(any))
        .thenAnswer((_) async => fakeBookmark);
    when(removeBookmarkUseCase.singleOutput(any))
        .thenAnswer((_) async => fakeBookmark);
  });

  group('Toggle bookmark use case', () {
    useCaseTest(
      'WHEN bookmark exists THEN remove bookmark',
      setUp: () {
        when(isBookmarkedUseCase.singleOutput(any))
            .thenAnswer((_) async => true);
      },
      build: () => toggleBookmarkUseCase,
      input: [CreateBookmarkFromDocumentUseCaseIn(document: fakeDocument)],
      verify: (_) {
        verifyInOrder([
          isBookmarkedUseCase.singleOutput(fakeDocument.documentUniqueId),
          removeBookmarkUseCase.singleOutput(fakeDocument.documentUniqueId),
        ]);
        verifyNoMoreInteractions(isBookmarkedUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
      },
    );

    useCaseTest(
      'WHEN bookmark does not exist THEN bookmark',
      setUp: () {
        when(isBookmarkedUseCase.singleOutput(fakeDocument.documentUniqueId))
            .thenAnswer((_) async => false);
      },
      build: () => toggleBookmarkUseCase,
      input: [CreateBookmarkFromDocumentUseCaseIn(document: fakeDocument)],
      verify: (_) {
        verifyInOrder([
          isBookmarkedUseCase.singleOutput(fakeDocument.documentUniqueId),
          createBookmarkFromDocumentUseCase.singleOutput(any),
        ]);
        verifyNoMoreInteractions(isBookmarkedUseCase);
        verifyNoMoreInteractions(createBookmarkFromDocumentUseCase);
        verifyNoMoreInteractions(removeBookmarkUseCase);
      },
    );
  });
}
