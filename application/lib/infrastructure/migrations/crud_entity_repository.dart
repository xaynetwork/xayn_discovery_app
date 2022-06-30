import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';

typedef MigrationTransformToMap<T> = Map Function(T object);
typedef MigrationTransformFromMap<T> = T Function(Map map);

class CrudEntityRepository<T extends DbEntity> {
  final HiveCrdt<String, dynamic> recordBox;
  final MigrationTransformToMap<T> toMap;
  final MigrationTransformFromMap<T?> fromMap;

  CrudEntityRepository({
    required String box,
    required this.toMap,
    required this.fromMap,
  }) : recordBox = HiveCrdt(Hive.box<Record>(box), HiveDB.nodeId);

  List<T?> getAll() => recordBox.values.map((e) => fromMap(e)).toList();

  T? getById(UniqueId id) => fromMap(recordBox.get(id.value));

  void saveValues(List<T?> list) {
    for (var e in list) {
      if (e != null) {
        recordBox.put(e.id.value, toMap(e));
      }
    }
  }

  void deleteValues(List<T?> list) {
    for (var e in list) {
      if (e != null) {
        recordBox.delete(e.id.value);
      }
    }
  }
}
