import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/document/document_wrapper.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/create_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/bookmark/get_bookmark_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/document/get_document_use_case.dart';

import '../test_utils/utils.dart';

void main() {
  late CreateBookmarkFromDocumentUseCase createBookmark;
  late GetDocumentUseCase getDocumentUseCase;
  late GetBookmarkUseCase getBookmarkUseCase;

  setUp(() async {
    await setupWidgetTest();
    // final documentRepository = HiveDocumentRepository(DocumentMapper());
    // final bookmarkRepository = HiveBookmarksRepository(BookmarkMapper());
    // final createBookmarkUseCase =
    //    di.get<>()
    // // ignore: prefer_function_declarations_over_variables
    //
    // final uriUseCase = DirectUriUseCase(
    //   client: FakeHttpClient.always404(),
    //   headers: {},
    //   cacheManager: createFakeImageCacheManager(),
    // );
    // final mapDocumentToCreateBookmarkParamUseCase =
    //     MapDocumentToCreateBookmarkParamUseCase(uriUseCase);
    // createBookmark = CreateBookmarkFromDocumentUseCase(
    //     mapDocumentToCreateBookmarkParamUseCase,
    //     createBookmarkUseCase,
    //     documentRepository);
    getDocumentUseCase = di.get();
    getBookmarkUseCase = di.get();
    createBookmark = di.get();
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

    expect(document, DocumentWrapper(fakeDocument));
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
}
