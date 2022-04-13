import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:test/test.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/migration_info_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migrations.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_migration_info_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

import '../util/test_hive.dart';

void main() async {
  late HiveMigrationInfoRepository repository;

  setUp(() async {
    EquatableConfig.stringify = true;
    await HiveSnapshot.load(version: 0);
    final mapper = MigrationInfoMapper();
    repository = HiveMigrationInfoRepository(mapper);
  });

  tearDown(() async {
    await HiveSnapshot.dispose();
  });

  group('Before Migration from 0 to 1: ', () {
    test('MigrationInfo should not exist', () async {
      expect(repository.migrationInfo!.version, 0);
    });

    test('AppSettings should be set', () async {
      expect(Hive.box<Map>(BoxNames.appSettings).values, isNotNull);
    });

/*
    test('There is a Collections should have a single item', () async {
      expect(Hive.box<Map>(BoxNames.collections).values, hasLength(1));
    });

    test('There are 2 Bookmarks', () async {
      expect(Hive.box<Map>(BoxNames.bookmarks).values, hasLength(2));
    });

    test('There are 3 Queries', () async {
      expect(Hive.box<Map>(BoxNames.queries).values, hasLength(3));
    });

    test('There are 24 Results', () async {
      expect(Hive.box<Map>(BoxNames.results).values, hasLength(24));
    });
    */
  });

  group('After Migration from 0 to 1: ', () {
    test('Status should be completed', () async {
      final migrations = HiveMigrations();

      var migrationStatus = await migrations.migrate(toVersion: 1);

      expect(migrationStatus, MigrationStatus.completed);
      expect(repository.migrationInfo!.version, 1);
    });

    test('AppSettings should not exist', () async {
      final migrations = HiveMigrations();

      await migrations.migrate(toVersion: 1);
      final data = Hive.box<Map>(BoxNames.appSettings).values;
      expect(data.length, 0);
    });

/*
    test('Collections should be empty', () async {
      final migrations = HiveMigrations();

      await migrations.migrate(toVersion: 1);

      expect(Hive.box<Map>(BoxNames.collections).values, isEmpty);
    });

    test('Bookmarks should be empty', () async {
      final migrations = HiveMigrations();

      await migrations.migrate(toVersion: 1);

      expect(Hive.box<Map>(BoxNames.bookmarks).values, isEmpty);
    });

    test('Queires should be empty', () async {
      final migrations = HiveMigrations();

      await migrations.migrate(toVersion: 1);

      expect(Hive.box<Map>(BoxNames.queries).values, isEmpty);
    });

    test('Results should be empty', () async {
      final migrations = HiveMigrations();

      await migrations.migrate(toVersion: 1);

      expect(Hive.box<Map>(BoxNames.results).values, isEmpty);
    });
    */
  });
}
