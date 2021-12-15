import 'package:meta/meta.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

/// Abstract interface to be implemented by Hive entities.
abstract class DbEntity {
  /// The id of Hive entity. Should not be overriden.
  @nonVirtual
  final UniqueId id;

  const DbEntity(this.id);
}
