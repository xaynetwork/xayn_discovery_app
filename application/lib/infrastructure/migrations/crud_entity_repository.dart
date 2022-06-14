import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';

class CrudEntityRepository<T extends DbEntity> {
  final HiveCrdt<String, dynamic> recordBox;

  final BaseDbEntityMapper<T> mapper;
  CrudEntityRepository({
    required String box,
    required this.mapper,
  }) : recordBox = HiveCrdt(Hive.box<Record>(box), HiveDB.nodeId);

  List<T?> getAll() => recordBox.values.map((e) => mapper.fromMap(e)).toList();

  T? getById(UniqueId id) => mapper.fromMap(recordBox.get(id.value));

  void saveValues(List<T> list) {
    for (var e in list) {
      recordBox.put(e.id.value, mapper.toMap(e));
    }
  }

  void deleteValues(List<T> list) {
    for (var e in list) {
      recordBox.delete(e.id.value);
    }
  }
}
