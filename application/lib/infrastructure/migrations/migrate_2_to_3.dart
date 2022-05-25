import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_status_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/base_migration.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/single_value_migration_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';

/// This Migration sets [isBetaUser] to true for users that used the app before.
// ignore: camel_case_types
class Migration_2_To_3 extends BaseDbMigration {
  @override
  Migration_2_To_3();

  @override
  Future<int> rollbackMigration(int fromVersion) async {
    return fromVersion;
  }

  @override
  Future<int> runMigration(int fromVersion) async {
    assert(fromVersion == 2);

    // Check if the user has any documents stored in the database.
    // If so, we assume it was a beta user.
    final recordBox = HiveCrdt(Hive.box<Record>('documents'), HiveDB.nodeId);
    Map? map = recordBox.get(0);
    final hasData = map != null;

    final repository = SingleValueMigrationRepository(
      box:
          'appStatus', // important hardcoded string to avoid accidental refactors
      key: AppStatus.globalId,
      transform: (map) {
        map[AppStatusFields.isBetaUser] = hasData;
        return map;
      },
    );
    repository.migrate();

    return 3;
  }
}
