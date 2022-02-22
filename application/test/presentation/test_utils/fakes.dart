import 'dart:typed_data';

import 'package:file/memory.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/direct_uri_use_case.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import 'mocks.mocks.dart';

final fakeDocument = Document(
  documentId: DocumentId(),
  userReaction: UserReaction.neutral,
  resource: NewsResource(
    thumbnail: Uri.parse(
        "https://www.reuters.com/resizer/K2oMuVX28AvBmJyt3DzgsFJPL9A=/1200x628/smart/filters:quality(80)/cloudfront-us-east-2.images.arcp"),
    sourceUrl: Uri.parse("https://www.msn.com"),
    country: 'US',
    language: 'en-US',
    rank: -1,
    score: .0,
    topic: 'topic',
    snippet:
        "The German financial regulator BaFin on Wednesday said it had fined Deutsche Bank 8.66 million euros (\$9.78 million) for control",
    title: "German finance watchdog fines Deutsche Bank for EURIBOR controls",
    url: Uri.parse(
        "https://www.msn.com/en-gb/finance/other/german-finance-watchdog-fines-deutsche-bank-for-euribor-controls/ar-AASeh7h"),
    datePublished: DateTime.parse("2021-12-29 07:59:49.000Z"),
  ),
  batchIndex: -1,
);

AppImageCacheManager createFakeImageCacheManager() {
  final imageCacheManager = MockAppImageCacheManager();
  when(imageCacheManager.getFileFromCache(any))
      .thenAnswer((realInvocation) async => null);
  when(imageCacheManager.putFile(any, any)).thenAnswer(
      (realInvocation) async => MemoryFileSystem().file('test.dart'));
  return imageCacheManager;
}

final fakeBookmark = Bookmark(
  id: UniqueId(),
  collectionId: UniqueId(),
  title: 'Bookmark1 title',
  image: Uint8List.fromList([1, 2, 3]),
  provider: DocumentProvider(
      name: 'Provider name', favicon: 'https://www.foo.com/favicon.ico'),
  createdAt: DateTime.now().toUtc().toString(),
);
