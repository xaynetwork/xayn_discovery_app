import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

void main() {
  group('Bookmark Object', () {
    final id = UniqueId();
    final collectionId = UniqueId();
    final image = Uint8List.fromList([1, 2, 3]);
    final providerThumbnail = Uint8List.fromList([4, 5, 6]);
    const bookmarkTitle = 'Bookmark title';
    const providerName = 'Provider name';
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
            providerName: providerName,
            providerThumbnail: providerThumbnail,
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
            providerName: '',
            providerThumbnail: providerThumbnail,
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
            providerName: providerName,
            providerThumbnail: providerThumbnail,
            createdAt: '',
          ),
          throwsAssertionError,
        );
      },
    );
  });
}
