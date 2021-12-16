import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';

class CollectionMapper extends BaseDbEntityMapper<Collection> {
  @override
  Collection? fromMap(Map? map) {
    if (map == null) return null;

    final id =
        map[CollectionMapperFields.id] ?? throwMapperException() as String;

    final name =
        map[CollectionMapperFields.name] ?? throwMapperException() as String;

    final index =
        map[CollectionMapperFields.index] ?? throwMapperException() as int;

    return Collection(
      id: UniqueId.fromTrustedString(id),
      name: name,
      index: index,
    );
  }

  @override
  DbEntityMap toMap(Collection entity) => {
        CollectionMapperFields.id: entity.id.value,
        CollectionMapperFields.name: entity.name,
        CollectionMapperFields.index: entity.index,
      };

  @override
  void throwMapperException([
    String exceptionText =
        'CollectionMapper: error occurred while mapping the object',
  ]) =>
      super.throwMapperException(exceptionText);
}

abstract class CollectionMapperFields {
  const CollectionMapperFields._();

  static const int id = 0;
  static const int name = 1;
  static const int index = 2;
}
