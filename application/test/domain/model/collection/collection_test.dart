import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

void main() {
  group('Collection Object', () {
    final id = UniqueId();
    test(
      'WHEN an empty name is given THEN throw assert exception',
      () {
        expect(
          () => Collection(id: id, name: '', index: 0),
          throwsAssertionError,
        );
      },
    );

    test(
      'WHEN a negative index is given THEN throw assert exception',
      () {
        expect(
          () => Collection(id: id, name: 'Collection name', index: -1),
          throwsAssertionError,
        );
      },
    );
  });
}
