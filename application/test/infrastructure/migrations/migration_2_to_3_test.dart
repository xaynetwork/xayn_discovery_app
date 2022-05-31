import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:test/test.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/extensions/hive_extension.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_status_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/migration_info_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migrations.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_migration_info_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';

import '../util/test_hive.dart';

void main() async {
  late HiveDbMigrationInfoRepository repository;
  late Box<Record> box;

  setUp(() async {
    EquatableConfig.stringify = true;
    HiveDB.registerHiveAdapters();
    await HiveSnapshot.load(version: 2);
    final mapper = MigrationInfoMapper();
    repository = HiveDbMigrationInfoRepository(mapper);
    box = Hive.safeBox<Record>(BoxNames.appStatus);
  });

  tearDown(() async {
    await HiveSnapshot.dispose();
  });

  group('Before Migration from 2 to 3: ', () {
    test('MigrationInfo should not exist', () async {
      expect(repository.migrationInfo!.version, 2);
    });

    test('AppStatus should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.appStatus).values, isNotNull);
    });
  });

  group('After Migration from 2 to 3: ', () {
    test('Status should be completed', () async {
      final migrations = HiveDbMigrations();
      final migrationStatus = await migrations.migrate(toVersion: 3);
      expect(migrationStatus, DbMigrationStatus.completed);
      expect(repository.migrationInfo!.version, 3);
    });

    test('AppStatus isBetaUser should be updated', () async {
      final oldAppSettings = box.get(AppStatus.globalId.value)!.value;
      final isBetaUserBefore =
          oldAppSettings[AppStatusFields.isBetaUser] as bool?;

      expect(isBetaUserBefore, isFalse);

      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 3);

      final newAppSettings = box.get(AppStatus.globalId.value)!.value;
      final isBetaUserAfter =
          newAppSettings[AppStatusFields.isBetaUser] as bool?;

      expect(isBetaUserAfter, isTrue);
    });
  });
}
