import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

void main() {
  group('Bookmark Object', () {
    final id = UniqueId();
    final collectionId = UniqueId();
    final image = Uint8List.fromList([1, 2, 3]);
    final provider = DocumentProvider(
        name: 'Provider name',
        favicon: Uri.parse('https://www.foo.com/favicon.ico'));
    const bookmarkTitle = 'Bookmark title';
    const createdAt = '2021-12-05';
    test(
      'WHEN an empty title is given THEN throw assert exception',
      () {
        expect(
          () => Bookmark(
            id: id,
            collectionId: collectionId,
            title: '',
            image: image,
            provider: provider,
            createdAt: createdAt,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'WHEN an empty provider name is given THEN does not throw assert exception',
      () {
        expect(
          () => Bookmark(
            id: id,
            collectionId: collectionId,
            title: bookmarkTitle,
            image: image,
            provider: null,
            createdAt: createdAt,
          ),
          predicate((bookmark) => bookmark != null),
        );
      },
    );

    test(
      'WHEN an empty createdAt is given THEN throw assert exception',
      () {
        expect(
          () => Bookmark(
            id: id,
            collectionId: collectionId,
            title: bookmarkTitle,
            image: image,
            provider: provider,
            createdAt: '',
          ),
          throwsAssertionError,
        );
      },
    );
  });
}
