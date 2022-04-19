import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:test/test.dart';
import 'package:xayn_discovery_app/domain/model/extensions/hive_extension.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/migration_info_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migrations.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_migration_info_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_db.dart';

import '../util/test_hive.dart';

void main() async {
  late HiveDbMigrationInfoRepository repository;

  setUp(() async {
    EquatableConfig.stringify = true;
    HiveDB.registerHiveAdapters();
    await HiveSnapshot.load(version: 0);
    final mapper = MigrationInfoMapper();
    repository = HiveDbMigrationInfoRepository(mapper);
  });

  tearDown(() async {
    await HiveSnapshot.dispose();
  });

  group('Before Migration from 0 to 1: ', () {
    test('MigrationInfo should not exist', () async {
      expect(repository.migrationInfo!.version, 0);
    });

    test('AppSettings should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.appSettings).values, isNotNull);
    });

    test('Collections should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.collections).values, isNotNull);
    });

    test('Bookmarks should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.bookmarks).values, isNotNull);
    });

    test('Documents should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.documents).values, isNotNull);
    });

    test('DocumentFilters should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.documentFilters).values, isNotNull);
    });

    test('AppStatus should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.appStatus).values, isNotNull);
    });

    test('Feed should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.feed).values, isNotNull);
    });

    test('FeedSettings should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.feedSettings).values, isNotNull);
    });

    test('FeedTypeMarkets should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.feedTypeMarkets).values, isNotNull);
    });

    test('ExplicitDocumentFeedback should be set', () async {
      expect(Hive.safeBox<Record>(BoxNames.explicitDocumentFeedback).values,
          isNotNull);
    });

    test('ReaderModeSettings should be set', () async {
      expect(
          Hive.safeBox<Record>(BoxNames.readerModeSettings).values, isNotNull);
    });

    test('ReaderModeSettings should be set', () async {
      expect(
          Hive.safeBox<Record>(BoxNames.readerModeSettings).values, isNotNull);
    });
  });

  group('After Migration from 0 to 1: ', () {
    test('Status should be completed', () async {
      final migrations = HiveDbMigrations();
      final migrationStatus = await migrations.migrate(toVersion: 1);
      expect(migrationStatus, DbMigrationStatus.completed);
      expect(repository.migrationInfo!.version, 1);
    });

    test('AppSettings should be set', () async {
      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 1);
      expect(Hive.safeBox<Record>(BoxNames.appSettings).values, isNotEmpty);
    });

    test('Collections should be set', () async {
      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 1);
      expect(Hive.safeBox<Record>(BoxNames.collections).values, isNotEmpty);
    });

    test('Bookmarks should be set', () async {
      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 1);
      expect(Hive.safeBox<Record>(BoxNames.bookmarks).values, isNotEmpty);
    });

    test('Documents should be set', () async {
      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 1);
      expect(Hive.safeBox<Record>(BoxNames.documents).values, isNotEmpty);
    });

    test('DocumentFilters should be set', () async {
      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 1);
      expect(Hive.safeBox<Record>(BoxNames.documentFilters).values, isNotEmpty);
    });

    test('AppStatus should be set', () async {
      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 1);
      expect(Hive.safeBox<Record>(BoxNames.appStatus).values, isNotEmpty);
    });

    test('Feed should be set', () async {
      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 1);
      expect(Hive.safeBox<Record>(BoxNames.feed).values, isNotEmpty);
    });

    test('FeedSettings should be set', () async {
      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 1);
      expect(Hive.safeBox<Record>(BoxNames.feedSettings).values, isNotEmpty);
    });

    test('FeedTypeMarkets should be set', () async {
      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 1);
      expect(Hive.safeBox<Record>(BoxNames.feedTypeMarkets).values, isNotEmpty);
    });

    test('ExplicitDocumentFeedback should be set', () async {
      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 1);
      expect(Hive.safeBox<Record>(BoxNames.explicitDocumentFeedback).values,
          isNotEmpty);
    });

    test('ReaderModeSettings should be set', () async {
      final migrations = HiveDbMigrations();
      await migrations.migrate(toVersion: 1);
      expect(
          Hive.safeBox<Record>(BoxNames.readerModeSettings).values, isNotEmpty);
    });
  });
}
