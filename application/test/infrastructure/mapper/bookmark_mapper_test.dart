import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/bookmark_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/uri_extensions.dart';

void main() async {
  final mapper = BookmarkMapper();

  group('BookmarkMapper:', () {
    const bookmarkTitleFromMap = 'FromMap bookmark title';
    const bookmarkTitleToMap = 'ToMap bookmark title';
    const providerNameFromMap = 'FromMap bookmark title';
    const providerNameToMap = 'ToMap bookmark title';
    const url = 'https://url_test.com';
    final id = UniqueId.fromTrustedString(
        Uri.parse(url).removeQueryParameters.toString());
    final collectionId = UniqueId();
    final documentId = UniqueId();
    final image = Uint8List.fromList([1, 2, 3]);
    const favicon = 'https://www.foo.com/favicon.ico';
    const createdAt = '2021-12-05';

    group('fromMap method:', () {
      final map = {
        0: id.value,
        1: collectionId.value,
        2: bookmarkTitleFromMap,
        3: image,
        4: providerNameFromMap,
        5: favicon,
        6: createdAt,
        7: documentId.value,
      };

      test(
          'WHEN a map with proper values is given THEN return Bookmark instance',
          () {
        final bookmark = mapper.fromMap(map);

        expect(bookmark is Bookmark, isTrue);
        expect(bookmark!.id, equals(id));
        expect(bookmark.documentId, equals(documentId));
        expect(bookmark.collectionId, equals(collectionId));
        expect(bookmark.title, equals(bookmarkTitleFromMap));
        expect(bookmark.image, equals(image));
        expect(bookmark.provider?.name, equals(providerNameFromMap));
        expect(bookmark.provider?.favicon, equals(favicon));
        expect(bookmark.createdAt, equals(createdAt));
      });
      test('WHEN id is null THEN throw a DbEntityMapperException ', () {
        final mapWithIdNull = Map.from(map);
        mapWithIdNull[0] = null;

        expect(
          () => mapper.fromMap(mapWithIdNull),
          throwsA(
            isA<DbEntityMapperException>(),
          ),
        );
      });
      test('WHEN collectionId is null THEN throw a DbEntityMapperException ',
          () {
        final mapWithCollectionIdNull = Map.from(map);
        mapWithCollectionIdNull[1] = null;

        expect(
          () => mapper.fromMap(mapWithCollectionIdNull),
          throwsA(
            isA<DbEntityMapperException>(),
          ),
        );
      });

      test('WHEN title is null THEN throw a DbEntityMapperException ', () {
        final mapWithTitleNull = Map.from(map);
        mapWithTitleNull[2] = null;

        expect(
          () => mapper.fromMap(mapWithTitleNull),
          throwsA(
            isA<DbEntityMapperException>(),
          ),
        );
      });

      test('WHEN image is null THEN set image null in bookmark', () {
        final mapWithImageNull = Map.from(map);
        mapWithImageNull[3] = null;
        final bookmark = mapper.fromMap(mapWithImageNull);

        expect(bookmark!.image, null);
      });

      test('WHEN providerThumbnail is null THEN the bookmark has no thumbnail',
          () {
        final mapWithProviderThumbnailNull = Map.from(map);
        mapWithProviderThumbnailNull[5] = null;
        final bookmark = mapper.fromMap(mapWithProviderThumbnailNull)!;

        expect(bookmark.provider?.favicon, null);
      });

      test('WHEN createdAt is null THEN throw a DbEntityMapperException', () {
        final mapWithCreatedAtNull = Map.from(map);
        mapWithCreatedAtNull[6] = null;

        expect(
          () => mapper.fromMap(mapWithCreatedAtNull),
          throwsA(
            isA<DbEntityMapperException>(),
          ),
        );
      });
    });

    group('toMap method:', () {
      final bookmark = Bookmark(
        documentId: documentId,
        collectionId: collectionId,
        title: bookmarkTitleToMap,
        image: image,
        provider: DocumentProvider(name: providerNameToMap, favicon: favicon),
        createdAt: createdAt,
        uri: Uri.parse(url),
      );

      test('given a Bookmark it returns a map with a proper structure', () {
        expect(
          mapper.toMap(bookmark),
          equals({
            0: id.value,
            1: collectionId.value,
            2: bookmarkTitleToMap,
            3: image,
            4: providerNameToMap,
            5: favicon,
            6: createdAt,
            7: documentId.value
          }),
        );
      });
    });
  });
}
