import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_status_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/base_migration.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/single_value_migration_repository.dart';

/// This Migration resets the [firstAppLaunchDate], required when enabling payments in prod.
// ignore: camel_case_types
class Migration_1_To_2 extends BaseDbMigration {
  @override
  Migration_1_To_2();

  @override
  Future<int> rollbackMigration(int fromVersion) async {
    return fromVersion;
  }

  @override
  Future<int> runMigration(int fromVersion) async {
    assert(fromVersion == 1);

    final repository = SingleValueMigrationRepository(
      box:
          'appStatus', // important hardcoded string to avoid accidental refactors
      key: AppStatus.globalId,
      transform: (map) {
        map[AppStatusFields.firstAppLaunchDate] = DateTime.now();
        return map;
      },
    );
    repository.migrate();

    return 2;
  }
}
