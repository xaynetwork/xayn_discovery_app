import 'dart:typed_data';

import 'package:crdt/crdt.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_adapters.dart';
import 'package:xayn_discovery_app/domain/model/extensions/hive_extension.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migrations.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';
import 'package:xayn_discovery_app/infrastructure/util/hive_constants.dart';

class HiveDB {
  static String? _nodeId;

  // workaround for testing, can't be null in productive context
  static String get nodeId => _nodeId ?? UniqueId().value;

  final DbMigrationStatus status;

  HiveDB._(this.status);

  static Future<HiveDB> init(String? path) async {
    final isPersistedOnDisk = path != null;

    if (isPersistedOnDisk) Hive.init(path);

    registerHiveAdapters();

    // Open this box only for migration info
    await _openBox<Record>(BoxNames.migrationInfo,
        inMemory: !isPersistedOnDisk);

    final status = isPersistedOnDisk
        ? await _performMigrations()
        : DbMigrationStatus.completed;

    await _openBoxes(inMemory: !isPersistedOnDisk);

    return HiveDB._(status);
  }

//Safely registers adapters, and checks if they have been registered before, which can happen during testing
  static void registerHiveAdapters() {
    // for some weird reason, has to be called individually, e.g. https://github.com/hivedb/hive/issues/499#issuecomment-757554658
    if (!Hive.isAdapterRegistered(hlcAdapterTypeId)) {
      Hive.registerAdapter(HlcAdapter(hlcAdapterTypeId));
    }
    if (!Hive.isAdapterRegistered(hlcCompactAdapterTypeId)) {
      Hive.registerAdapter(HlcCompatAdapter(hlcCompactAdapterTypeId, nodeId));
    }
    if (!Hive.isAdapterRegistered(recordAdapterTypeId)) {
      Hive.registerAdapter(RecordAdapter(recordAdapterTypeId));
    }
  }

  static Future<void> _openBoxes({bool inMemory = false}) async {
    await Future.wait(
      BoxNamesExtension.valuesWithoutMigrationInfo.map(
        (boxName) => _openBox<Record>(boxName, inMemory: inMemory),
      ),
    );
  }

  static Future<Box<T>> _openBox<T>(
    BoxNames boxNames, {
    bool inMemory = false,
  }) async {
    if (Hive.isBoxOpen(boxNames.name)) {
      return Hive.safeBox<T>(boxNames);
    } else {
      return Hive.openSafeBox<T>(boxNames,
          bytes: inMemory ? Uint8List(0) : null);
    }
  }

  static Future<void> _closeBoxes() => Hive.close();

  static Future<DbMigrationStatus> _performMigrations() async {
    // Migrations should all expect open boxes finish with open boxes (easier to test)
    // if they change the box type, they should close the respective box and open a new one
    final status = await HiveDbMigrations().migrate();
    // close all boxes, so they can be opened safely with correct types
    await _closeBoxes();
    return status;
  }

  /// Deletes all currently open Hive boxes from disk.
  /// The home directory will not be deleted.
  Future<void> destroy() => Hive.deleteFromDisk();

  /// Closes all open Hive boxes.
  Future<void> dispose() => _closeBoxes();
}
