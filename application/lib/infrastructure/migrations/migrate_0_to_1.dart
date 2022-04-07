import 'package:hive/hive.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/base_migration.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

/// This Migration migrates from a stale old db version before migrations have been added
/// It basically delets the old database.
// ignore: camel_case_types
class Migration_0_To_1 extends BaseMigration {
  @override
  Migration_0_To_1();

  @override
  Future<int> rollbackMigration(int fromVersion) async {
    return fromVersion;
  }

  @override
  Future<int> runMigration(int fromVersion) async {
    assert(fromVersion == 0);

    Future<void> clear(String boxName) async {
      await Hive.box<Map>(boxName).clear();
    }

    await clear(BoxNames.appSettings);
    await clear(BoxNames.collections);
    await clear(BoxNames.bookmarks);
    await clear(BoxNames.documents);
    await clear(BoxNames.documentFilters);
    await clear(BoxNames.appStatus);
    await clear(BoxNames.feed);
    await clear(BoxNames.feedSettings);
    await clear(BoxNames.feedTypeMarkets);
    await clear(BoxNames.explicitDocumentFeedback);
    await clear(BoxNames.readerModeSettings);
    await clear(BoxNames.migrationInfo);

    return 1;
  }
}
