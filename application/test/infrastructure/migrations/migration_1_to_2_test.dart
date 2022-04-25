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
    await HiveSnapshot.load(version: 1);
    final mapper = MigrationInfoMapper();
    repository = HiveDbMigrationInfoRepository(mapper);
    box = Hive.safeBox<Record>(BoxNames.appStatus);
  });

  tearDown(() async {
    await HiveSnapshot.dispose();
  });

  group('Before Migration from 1 to 2: ', () {
    test('MigrationInfo should not exist', () async {
      expect(repository.migrationInfo!.version, 1);
    });

    test('AppStatus should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.appStatus).values, isNotNull);
    });
  });

  group('After Migration from 1 to 2: ', () {
    test('Status should be completed', () async {
      final migrations = HiveDbMigrations();
      final migrationStatus = await migrations.migrate(toVersion: 2);
      expect(migrationStatus, DbMigrationStatus.completed);
      expect(repository.migrationInfo!.version, 2);
    });

    test('AppStatus firstAppLaunchDateBefore should be updated', () async {
      final oldAppSettings = box.get(AppStatus.globalId.value)!.value;
      final firstAppLaunchDateBefore =
          oldAppSettings[AppStatusFields.firstAppLaunchDate] as DateTime;

      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 2);

      final newAppSettings = box.get(AppStatus.globalId.value)!.value;
      final firstAppLaunchDateAfter =
          newAppSettings[AppStatusFields.firstAppLaunchDate] as DateTime;

      expect(
          firstAppLaunchDateBefore.isBefore(firstAppLaunchDateAfter), isTrue);
    });
  });
}
