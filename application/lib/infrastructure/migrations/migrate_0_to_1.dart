import 'package:xayn_discovery_app/infrastructure/migrations/base_migration.dart';

/// This Migration migrates from a stale old db version before migrations have been added
/// It basically delets the old database.
// ignore: camel_case_types
class Migration_0_To_1 extends BaseDbMigration {
  @override
  Migration_0_To_1();

  @override
  Future<int> rollbackMigration(int fromVersion) async {
    return fromVersion;
  }

  @override
  Future<int> runMigration(int fromVersion) async {
    assert(fromVersion == 0);

    // The migration code goes here. This is a test implementation,
    // which only shows the correct approach of adding new migrations.

    return 1;
  }
}
