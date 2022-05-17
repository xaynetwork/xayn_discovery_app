import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';

typedef MigrationTransform = Map Function(Map map);

class SingleValueMigrationRepository {
  final UniqueId key;
  final MigrationTransform transform;
  final HiveCrdt<String, dynamic> recordBox;

  SingleValueMigrationRepository({
    required String box,
    required this.key,
    required this.transform,
  }) : recordBox = HiveCrdt(Hive.box<Record>(box), HiveDB.nodeId);

  void migrate() {
    Map? map = recordBox.get(key.value);
    if (map != null) {
      transform(map);
      recordBox.put(key.value, map);
    }
  }
}
