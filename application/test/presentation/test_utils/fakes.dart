import 'package:file/memory.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/image_processing/direct_uri_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

import 'mocks.mocks.dart';

final fakeDocument = Document(
  documentId: DocumentId(),
  feedback: DocumentFeedback.neutral,
  webResource: WebResource(
    displayUrl: Uri.parse(
        "https://www.reuters.com/resizer/K2oMuVX28AvBmJyt3DzgsFJPL9A=/1200x628/smart/filters:quality(80)/cloudfront-us-east-2.images.arcp"),
    snippet:
        "The German financial regulator BaFin on Wednesday said it had fined Deutsche Bank 8.66 million euros (\$9.78 million) for control",
    title: "German finance watchdog fines Deutsche Bank for EURIBOR controls",
    url: Uri.parse(
        "https://www.msn.com/en-gb/finance/other/german-finance-watchdog-fines-deutsche-bank-for-euribor-controls/ar-AASeh7h"),
    datePublished: DateTime.parse("2021-12-29 07:59:49.000Z"),
    provider: const WebResourceProvider(
        name: " Reuters on MSN.com", thumbnail: null
        // "https://www.bing.com/th?id=ODF.jFXbg3L7Ce_1pS4_IOR8CA&pid=news?w=64"
        ),
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
