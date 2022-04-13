import 'package:xayn_discovery_app/infrastructure/migrations/migration_info.dart';

/// Repository interface for storing global app settings.
abstract class MigrationInfoRepository {
  /// The [MigrationInfo] setter method.
  void save(MigrationInfo migrationInfo);

  /// The [MigrationInfo] getter method.
  MigrationInfo? get migrationInfo;
}
