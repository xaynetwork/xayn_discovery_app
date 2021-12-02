import 'package:xayn_discovery_app/presentation/utils/logger.dart';

abstract class BaseMigration {
  String get migrationId => runtimeType.toString();

  // returns the version that it migrated to
  Future<int> runMigration(int fromVersion);

  // returns the version that it rolledback to
  Future<int> rollbackMigration(int fromVersion);

  /// Executes the migration. First tries to run it,
  /// if `runMigration` throws, then it will try to
  /// `rollbackMigration`.
  Future<int> execute(int fromVersion) async {
    try {
      final newVersion = await runMigration(fromVersion);
      return newVersion;
    } catch (e) {
      logger.e(e);
      return await rollbackMigration(fromVersion);
    }
  }
}
