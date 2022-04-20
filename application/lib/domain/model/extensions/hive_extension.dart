import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

extension HiveExtension on HiveInterface {
  Box<E> safeBox<E>(BoxNames boxNames) => box<E>(boxNames.name);

  Future<Box<E>> openSafeBox<E>(
    BoxNames boxNames, {
    Uint8List? bytes,
  }) =>
      openBox<E>(
        boxNames.name,
        bytes: bytes,
      );
}
