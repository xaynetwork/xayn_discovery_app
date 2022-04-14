import 'dart:io';
import 'dart:typed_data';

/// NOTE: Does not support any flutter dependencies thus can not load flutter code,
/// so be careful when importing packages.
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_adapters.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/bookmark/bookmark.dart';
import 'package:xayn_discovery_app/domain/model/collection/collection.dart';
import 'package:xayn_discovery_app/domain/model/document/document_provider.dart';
import 'package:xayn_discovery_app/domain/model/document/document_wrapper.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/document_filter/document_filter.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type_markets.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_settings.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_status_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_theme_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_version_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/bookmark_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/collection_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/db_entity_to_feed_market_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/document_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/explicit_document_feedback_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/feed_type_markets_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/migration_info_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migration_info.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_bookmarks_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_collections_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_document_filter_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_document_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_explicit_document_feedback_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_feed_type_markets_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_migration_info_repository.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_reader_mode_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';
import 'package:xayn_discovery_app/infrastructure/util/discovery_engine_markets.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_constants.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// Creates a database snapshot in the given directory
void main(List<String> args) async {
  EquatableConfig.stringify = true;

  if (args.length != 2) {
    // ignore: avoid_print
    print(
        'Need to provide a snapshot directory (i.e. test/db_snapshots/v42) and version (i.e. 42)');
    exit(1);
  }

  final snapshotDir = args[0];
  final version = int.tryParse(args[1]);

  // ignore: avoid_print
  print('Create snapshot in $args');

  // use alternative method when creating an older map based snapshot
  await _prepareHiveRecords(snapshotDir);

  _createMigrationInfo(version!);
  _createAppSettings();
  final colId1 = UniqueId();
  _createCollections(
    {colId1: 'Test Collection'},
  );
  _createBookmarks();
  _createDocuments();
  _createDocumentFilters();
  _createAppStatus();
  _createFeed();
  _createFeedSettings();
  _createFeedTypeMarkets();
  _createExplicitDocumentFeedback();
  _createReaderModeSettings();
}

void _createMigrationInfo(int version) async {
  final mapper = MigrationInfoMapper();
  final repository = HiveMigrationInfoRepository(mapper);
  final migrationInfo = MigrationInfo(version: version);
  repository.save(migrationInfo);
}

void _createAppSettings() {
  const mapper = AppSettingsMapper(
    IntToAppThemeMapper(),
    AppThemeToIntMapper(),
  );
  final repository = HiveAppSettingsRepository(mapper);
  final appSettings = AppSettings.initial();
  repository.save(appSettings);
}

void _createCollections(Map<UniqueId, String> collections) {
  final mapper = CollectionMapper();
  final repository = HiveCollectionsRepository(mapper);

  for (var index = 0; index < collections.entries.length; index++) {
    final collection = collections.entries.elementAt(index);
    repository.save(Collection(
      id: collection.key,
      name: collection.value,
      index: index,
    ));
  }
}

void _createBookmarks() {
  final mapper = BookmarkMapper();
  final repository = HiveBookmarksRepository(mapper);
  final provider = DocumentProvider(
    name: 'Provider name',
    favicon: 'https://www.foo.com/favicon.ico',
  );
  final bookmark = Bookmark(
    id: UniqueId(),
    collectionId: UniqueId(),
    title: 'Bookmark title',
    image: Uint8List.fromList([1, 2, 3]),
    provider: provider,
    createdAt: DateTime.now().toUtc().toString(),
  );
  repository.save(bookmark);
}

void _createDocuments() {
  final mapper = DocumentMapper();
  final repository = HiveDocumentRepository(mapper);
  final document = Document(
    documentId: DocumentId(),
    userReaction: UserReaction.neutral,
    batchIndex: -1,
    resource: NewsResource(
      title: '',
      snippet: '',
      url: Uri.base,
      sourceDomain: Source('example'),
      image: Uri.base,
      datePublished: DateTime(2022),
      country: 'US',
      language: 'en-US',
      rank: -1,
      score: .0,
      topic: 'topic',
    ),
  );
  final documentWrapper = DocumentWrapper(document);
  repository.save(documentWrapper);
}

void _createDocumentFilters() {
  final repository = HiveDocumentFilterRepository();
  final documentFilter = DocumentFilter.fromSource('xayn.com');
  repository.save(documentFilter);
}

void _createAppStatus() {
  const mapper = AppStatusMapper(
    MapToAppVersionMapper(),
    AppVersionToMapMapper(),
  );
  final repository = HiveAppStatusRepository(mapper);
  final appStatus = AppStatus.initial();
  repository.save(appStatus);
}

void _createFeed() {
  final mapper = FeedMapper();
  final repository = HiveFeedRepository(mapper);
  final feed = Feed(
    id: UniqueId(),
    cardIndexFeed: 0,
    cardIndexSearch: 0,
  );
  repository.save(feed);
}

void _createFeedSettings() {
  final mapper = FeedSettingsMapper(
    DbEntityMapToFeedMarketMapper(),
    FeedMarketToDbEntityMapMapper(),
  );
  final repository = HiveFeedSettingsRepository(mapper);
  final feedSettings = FeedSettings.initial();
  repository.save(feedSettings);
}

void _createFeedTypeMarkets() {
  final mapper = FeedTypeMarketsMapper(
    DbEntityMapToFeedMarketMapper(),
    FeedMarketToDbEntityMapMapper(),
  );
  final repository = HiveFeedTypeMarketsRepository(mapper);
  final feedMarkets = {defaultFeedMarket};
  final feedTypeMarkets = FeedTypeMarkets.forFeed(feedMarkets);
  repository.save(feedTypeMarkets);
}

void _createExplicitDocumentFeedback() {
  final mapper = ExplicitDocumentFeedbackMapper();
  final repository = HiveExplicitDocumentFeedbackRepository(mapper);
  final explicitDocumentFeedback = ExplicitDocumentFeedback(id: UniqueId());
  repository.save(explicitDocumentFeedback);
}

void _createReaderModeSettings() {
  const mapper = ReaderModeSettingsMapper();
  final repository = HiveReaderModeSettingsRepository(mapper);
  final readerModeSettings = ReaderModeSettings.initial();
  repository.save(readerModeSettings);
}

// can be used for older snapshots
// ignore: unused_element
Future _prepareHive(String snapshotDir) async {
  Hive.init(snapshotDir);
  await _openBoxes<Map>();
  await Hive.deleteFromDisk();
  await _openBoxes<Map>();
}

Future _prepareHiveRecords(String snapshotDir) async {
  Hive
    ..init(snapshotDir)
    ..registerAdapter(HlcAdapter(hlcAdapterTypeId))
    ..registerAdapter(
        HlcCompatAdapter(hlcCompactAdapterTypeId, UniqueId().value))
    ..registerAdapter(RecordAdapter(recordAdapterTypeId));
  await _openBoxes<Record>();
  await Hive.deleteFromDisk();
  await _openBoxes<Record>();
}

Future _openBoxes<T>() async {
  await Hive.openBox<T>(BoxNames.appSettings);
  await Hive.openBox<T>(BoxNames.collections);
  await Hive.openBox<T>(BoxNames.bookmarks);
  await Hive.openBox<T>(BoxNames.documents);
  await Hive.openBox<T>(BoxNames.documentFilters);
  await Hive.openBox<T>(BoxNames.appStatus);
  await Hive.openBox<T>(BoxNames.feed);
  await Hive.openBox<T>(BoxNames.feedSettings);
  await Hive.openBox<T>(BoxNames.feedTypeMarkets);
  await Hive.openBox<T>(BoxNames.explicitDocumentFeedback);
  await Hive.openBox<T>(BoxNames.readerModeSettings);
  await Hive.openBox<T>(BoxNames.migrationInfo);
}
