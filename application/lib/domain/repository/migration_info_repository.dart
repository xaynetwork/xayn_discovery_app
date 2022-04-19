import 'package:xayn_discovery_app/infrastructure/migrations/migration_info.dart';

/// Repository interface for storing global app settings.
abstract class DbMigrationInfoRepository {
  /// The [DbMigrationInfo] setter method.
  void save(DbMigrationInfo migrationInfo);

  /// The [DbMigrationInfo] getter method.
  DbMigrationInfo? get migrationInfo;
}
