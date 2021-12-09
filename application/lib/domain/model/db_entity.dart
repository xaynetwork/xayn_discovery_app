import 'package:flutter/foundation.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

abstract class DbEntity {
  @nonVirtual
  final UniqueId id;

  const DbEntity(this.id);
}
