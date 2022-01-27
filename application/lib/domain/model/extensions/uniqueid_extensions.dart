import 'package:uuid/uuid.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

extension UniqueIdExtensions on UniqueId {
  DocumentId get documentId =>
      DocumentId.fromBytes(Uuid.parseAsByteList(value));
}
