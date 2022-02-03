import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/collection_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

import 'hive_repository.dart';

const maxCollectionNameLength = 20;

@Singleton(as: CollectionsRepository)
class HiveCollectionsRepository extends HiveRepository<Collection>
    implements CollectionsRepository {
  final CollectionMapper _mapper;

  HiveCollectionsRepository(this._mapper);

  @override
  BaseDbEntityMapper<Collection> get mapper => _mapper;

  @override
  Box<Record> get box => Hive.box<Record>(BoxNames.collections);

  /// return the list of collection sorted in the following order:
  /// 1. Default collection
  /// 2. Other collections ordered alphabetically
  @override
  List<Collection> getAll() {
    final values = super.getAll();
    if (values.isEmpty || values.length == 1) {
      return values;
    }
    final defaultCollection = values.firstWhere((it) => it.isDefault);
    values.remove(defaultCollection);
    values.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return [defaultCollection, ...values];
  }

  @override
  int getLastCollectionIndex() => getAll().last.index;

  @override
  bool isCollectionNameUsed(String name) {
    final values = getAll();
    for (final value in values) {
      if (value.name.trim() == name.trim()) {
        return true;
      }
    }
    return false;
  }

  @override
  bool isCollectionNameNotValid(String name) =>
      name.trim().length > maxCollectionNameLength || name.trim().isEmpty;
}
