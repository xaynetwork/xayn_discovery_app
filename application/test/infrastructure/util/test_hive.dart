import 'dart:io' as io;
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:xayn_discovery_app/domain/model/extensions/hive_extension.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

/// In order to create a new snapshot run:
/// `dart test/db_snapshots/create_snapshot.dart test/db_snapshots/vXXX`
///
/// where `XXX` is the app db version
/// if you need to access old boxes, which will be removed from Hive,
/// then you can pass those via [deprecatedBoxes]
class HiveSnapshot {
  static Future<void> load({
    required int version,
    List<BoxNames> deprecatedBoxes = const [],
    bool openBoxes = true,
  }) async {
    final path = _createAbsolutePath('test/db_snapshots/v$version');
    if (openBoxes) {
      await _openBoxes(path, deprecatedBoxes);
    }
  }

  static Future<void> _openBoxes(String path, List<BoxNames> deprecatedBoxes) =>
      Future.wait([
        ...BoxNames.values.map((boxName) => _openBox(boxName, path)),
        ...deprecatedBoxes.map((boxName) => _openBox(boxName, path)),
      ]);

  static Future<Box<Record>> _openBox(BoxNames boxNames, String path) {
    var file = io.File('$path/${boxNames.name.toLowerCase()}.hive');
    // ignore: avoid_print
    print('load $file which exists: ${file.existsSync()}');
    return Hive.openSafeBox<Record>(boxNames,
        bytes: file.existsSync() ? file.readAsBytesSync() : Uint8List(0));
  }

  static String _createAbsolutePath(String relativePath) {
    var dir = io.Directory.current.path;
    if (dir.endsWith('/test')) {
      dir = dir.replaceAll('/test', '');
    }
    return '$dir/$relativePath';
  }

  static Future<void> dispose() => Hive.close();
}
