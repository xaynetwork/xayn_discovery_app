import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

extension DocumentIdUtils on DocumentId {
  UniqueId get uniqueId => UniqueId.fromTrustedString(toString());
}
