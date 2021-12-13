import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/repository/collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/collection_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

import 'hive_repository.dart';

@Singleton(as: CollectionsRepository)
class HiveCollectionsRepository extends HiveRepository<Collection>
    implements CollectionsRepository {
  final CollectionMapper _mapper;

  HiveCollectionsRepository(this._mapper);

  @override
  BaseDbEntityMapper<Collection> get mapper => _mapper;

  @override
  Box<Record> get box => Hive.box<Record>(BoxNames.collections);

  @override
  set collection(Collection collection) => entity = collection;
}
