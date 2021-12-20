import 'package:test/test.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/collection_mapper.dart';

void main() async {
  final mapper = CollectionMapper();

  group('CollectionMapper:', () {
    final id = UniqueId();
    const collectionTitleFromMap = 'FromMap Collection name';
    const collectionTitleToMap = 'ToMap collection name';

    group('fromMap method:', () {
      final map = {
        0: id.value,
        1: collectionTitleFromMap,
        2: 0,
      };

      test(
          'WHEN a map with proper values is given THEN returns Collection instance',
          () {
        final collection = mapper.fromMap(map);

        expect(collection is Collection, isTrue);
        expect(collection!.id, equals(id));
        expect(collection.index, equals(0));
        expect(collection.name, equals('FromMap Collection name'));
      });

      test('WHEN id is null THEN throw a DbEntityMapperException', () {
        final mapWithIdNull = Map.from(map);
        mapWithIdNull[0] = null;

        expect(
          () => mapper.fromMap(mapWithIdNull),
          throwsA(
            isA<DbEntityMapperException>(),
          ),
        );
      });

      test('WHEN name is null THEN throw a DbEntityMapperException', () {
        final mapWithNameNull = Map.from(map);
        mapWithNameNull[1] = null;

        expect(
          () => mapper.fromMap(mapWithNameNull),
          throwsA(
            isA<DbEntityMapperException>(),
          ),
        );
      });

      test('WHEN index is null THEN throw a DbEntityMapperException', () {
        final mapWithIndexNull = Map.from(map);
        mapWithIndexNull[2] = null;

        expect(
          () => mapper.fromMap(mapWithIndexNull),
          throwsA(
            isA<DbEntityMapperException>(),
          ),
        );
      });
    });

    group('toMap method:', () {
      final collection = Collection(
        id: id,
        name: collectionTitleToMap,
        index: 0,
      );

      test('given a Collection it returns a map with a proper structure', () {
        expect(
          mapper.toMap(collection),
          equals({
            0: id.value,
            1: collectionTitleToMap,
            2: 0,
          }),
        );
      });
    });
  });
}
