import 'package:hive/hive.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/migration_info_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/base_migration.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migrate_0_to_1.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migrate_1_to_2.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migration_info.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_migration_info_repository.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

enum DbMigrationStatus { completed, failed }

abstract class DbMigrations {
  /// Run migration. The `toVersion` param is optional and should be used
  /// only in tests.
  Future<DbMigrationStatus> migrate({int toVersion});
}

/// This table defines all the migrations from version X to any other version.
/// Those migrations will be executed in sequence.
final _migrations = <int, BaseDbMigration Function()>{
  0: () => Migration_0_To_1(),
  1: () => Migration_1_To_2(),
};

typedef BoxOpener<T> = Box<T> Function(String name);

class HiveDbMigrations implements DbMigrations {
  final _repository = HiveDbMigrationInfoRepository(MigrationInfoMapper());

  HiveDbMigrations();

  @override
  Future<DbMigrationStatus> migrate({int? toVersion}) async {
    // ignore: prefer_typing_uninitialized_variables
    var currentVersion;

    final versionToMigrate = toVersion ?? DbMigrationInfo.dbVersion;

    // No migrations required. Save the latest version and return.
    if (_readCurrentVersion() == null) {
      await _writeVersion(DbMigrationInfo.dbVersion);
      return DbMigrationStatus.completed;
    }

    while ((currentVersion = _readCurrentVersion()) != versionToMigrate) {
      // Find the next migration
      final step = _migrations[currentVersion];

      if (step == null) {
        logger.i(
            'No migration found for $currentVersion will write latest version to db');
        await _writeVersion(DbMigrationInfo.dbVersion);
      } else {
        final nextStep = step();
        logger.i('Will execute $nextStep as migration from $currentVersion');
        final newVersion = await nextStep.execute(currentVersion);
        logger.i('$nextStep migrated db from $currentVersion to $newVersion');

        // migration failed
        if (newVersion <= currentVersion) {
          logger.i(
              '$newVersion is lower or equal like current version, migration failed.');
          return DbMigrationStatus.failed;
        } else {
          logger.i('writing new version $newVersion to migration info.');
          await _writeVersion(newVersion);
        }
      }
    }

    return DbMigrationStatus.completed;
  }

  int? _readCurrentVersion() {
    final info = _repository.migrationInfo;
    return info?.version;
  }

  Future<void> _writeVersion(int version) async {
    return _repository.save(DbMigrationInfo(version: version));
  }
}
