import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/bookmark_use_cases_errors.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/remove_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document/get_document_use_case.dart';

import '../../test_utils/fakes.dart';
import '../../test_utils/widget_test_utils.dart';

void main() {
  late CreateBookmarkFromDocumentUseCase createBookmark;
  late GetDocumentUseCase getDocumentUseCase;
  late GetBookmarkUseCase getBookmarkUseCase;
  late RemoveBookmarkUseCase removeBookmarkUseCase;

  setUp(() async {
    await setupWidgetTest();
    getDocumentUseCase = di.get();
    getBookmarkUseCase = di.get();
    createBookmark = di.get();
    removeBookmarkUseCase = di.get();
  });

  tearDown(() async {
    tearDownWidgetTest();
  });

  test('Creating a non existing bookmark yields a non null object.', () async {
    final bookmark = await createBookmark.singleOutput(
        CreateBookmarkFromDocumentUseCaseIn(document: fakeDocument));

    expect(bookmark, isNotNull);
  });

  test('Creating bookmark from a document also stores the document.', () async {
    final bookmark = await createBookmark.singleOutput(
        CreateBookmarkFromDocumentUseCaseIn(document: fakeDocument));
    final document = await getDocumentUseCase.singleOutput(bookmark.id);

    expect(document, fakeDocument);
  });

  test(
      'Creating bookmark from a document, allows to retrieve the bookmark by the document id',
      () async {
    final original = await createBookmark.singleOutput(
        CreateBookmarkFromDocumentUseCaseIn(document: fakeDocument));
    final secondCall =
        await getBookmarkUseCase.singleOutput(fakeDocument.documentId.uniqueId);

    expect(original, secondCall);
  });

  test('After deleting a bookmark also the corresponding document is removed.',
      () async {
    final bookmark = await createBookmark.singleOutput(
        CreateBookmarkFromDocumentUseCaseIn(document: fakeDocument));
    await removeBookmarkUseCase.singleOutput(bookmark.id);

    expect(() async => await getDocumentUseCase.singleOutput(bookmark.id),
        throwsA(BookmarkUseCaseError.tryingToGetNotExistingBookmark));
  });
}
