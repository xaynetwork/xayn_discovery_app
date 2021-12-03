import 'package:hive/hive.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/base_migration.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migration_info.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migration_info_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/utils/box_names.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';

enum MigrationStatus { completed, failed }

abstract class Migrations {
  /// Run migration. The `toVersion` param is optional and should be used
  /// only in tests.
  Future<MigrationStatus> migrate({int toVersion});
}

/// This table defines all the migrations from version X to any other version.
/// Those migrations will be executed in sequence.
final _migrations = <int, BaseMigration Function()>{
  // Add migrations here. Follow the same process as in xayn_search.
};

typedef BoxOpener<T> = Box<T> Function(String name);

class HiveMigrations implements Migrations {
  final _repo = HiveMigrationInfoRepo();

  HiveMigrations();

  @override
  Future<MigrationStatus> migrate({int? toVersion}) async {
    int? currentVersion;

    final versionToMigrate = toVersion ?? MigrationInfo.dbVersion;

    while ((currentVersion = _readCurrentVersion()) != versionToMigrate) {
      // Find the next migration
      final step = _migrations[currentVersion];

      if (step == null) {
        logger.i(
            'No migration found for $currentVersion will write latest version to db');
        await _writeVersion(MigrationInfo.dbVersion);
      } else {
        final nextStep = step();
        logger.i('Will execute $nextStep as migration from $currentVersion');
        final newVersion = await nextStep.execute(currentVersion);
        logger.i('$nextStep migrated db from $currentVersion to $newVersion');

        // migration failed
        if (newVersion <= currentVersion) {
          logger.i(
              '$newVersion is lower or equal like current version, migration failed.');
          return MigrationStatus.failed;
        } else {
          logger.i('writing new version $newVersion to migration info.');
          await _writeVersion(newVersion);
        }
      }
    }

    return MigrationStatus.completed;
  }

  int _readCurrentVersion() {
    final info = _repo.getMigrationInfo();
    return info?.version ?? 0;
  }

  Future<void> _writeVersion(int version) async {
    return _repo.save(MigrationInfo(version: version));
  }
}

class HiveMigrationInfoRepo {
  static const _migrationInfoKey = 0;
  final _migrationInfoBox = Hive.box<Map>(BoxNames.migrationInfo);
  final _mapper = MigrationInfoMapper();

  Future save(MigrationInfo info) async {
    await _migrationInfoBox.put(_migrationInfoKey, _mapper.toMap(info));
  }

  MigrationInfo? getMigrationInfo() {
    return _mapper.fromMap(_migrationInfoBox.get(0));
  }
}
