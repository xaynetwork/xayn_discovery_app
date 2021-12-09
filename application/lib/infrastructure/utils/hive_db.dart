import 'dart:typed_data';

import 'package:crdt/crdt.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_adapters.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/utils/box_names.dart';
import 'package:xayn_discovery_app/infrastructure/utils/hive_constants.dart';

class HiveDB {
  static String? _nodeId;

  // workaround for testing, can't be null in productive context
  static String get nodeId => _nodeId ?? UniqueId().value;

  HiveDB._();

  static Future<HiveDB> init(String? path) async {
    final isPersistedOnDisk = path != null;

    if (isPersistedOnDisk) {
      Hive.init(path!);
    }
    registerHiveAdapters();

    await _openBoxes(inMemory: !isPersistedOnDisk);

    return HiveDB._();
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
    await Future.wait([
      _openBox<Record>(BoxNames.appSettings, inMemory: inMemory),
    ]);
  }

  static Future<Box<T>> _openBox<T>(
    String name, {
    bool inMemory = false,
  }) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    } else {
      return Hive.openBox<T>(name, bytes: inMemory ? Uint8List(0) : null);
    }
  }

  /// Deletes all currently open Hive boxes from disk.
  /// The home directory will not be deleted.
  Future<void> destroy() => Hive.deleteFromDisk();

  /// Closes all open Hive boxes.
  Future<void> dispose() => Hive.close();
}
