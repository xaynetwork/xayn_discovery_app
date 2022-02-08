import 'dart:typed_data';

import 'package:file/memory.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/direct_uri_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import 'mocks.mocks.dart';

final fakeDocument = Document(
  documentId: DocumentId(),
  feedback: DocumentFeedback.neutral,
  resource: NewsResource(
    sourceUrl: Uri.parse("https://www.reuters.com/"),
    snippet:
        "The German financial regulator BaFin on Wednesday said it had fined Deutsche Bank 8.66 million euros (\$9.78 million) for control",
    title: "German finance watchdog fines Deutsche Bank for EURIBOR controls",
    url: Uri.parse(
        "https://www.msn.com/en-gb/finance/other/german-finance-watchdog-fines-deutsche-bank-for-euribor-controls/ar-AASeh7h"),
    datePublished: DateTime.parse("2021-12-29 07:59:49.000Z"),
    thumbnail: null,
    language: '',
    country: '',
    topic: '',
    score: null,
    rank: 0,
  ),
  nonPersonalizedRank: 0,
  personalizedRank: 0,
  isActive: true,
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
