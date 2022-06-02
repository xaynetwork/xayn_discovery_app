import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_status_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/base_migration.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/single_value_migration_repository.dart';

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

    final repository = SingleValueMigrationRepository(
      box:
          'appStatus', // important hardcoded string to avoid accidental refactors
      key: AppStatus.globalId,
      transform: (map) {
        // Check if the user has any previous sessions.
        // If so, we assume it was a beta user.
        final numberOfSessions =
            map[AppStatusFields.numberOfSessions] as int? ?? 0;
        map[AppStatusFields.isBetaUser] = numberOfSessions > 0;
        return map;
      },
    );
    repository.migrate();

    return 3;
  }
}
