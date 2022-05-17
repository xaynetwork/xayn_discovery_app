import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

class DbMigrationInfo extends DbEntity {
  /// Increment this version for each change on the DB structure, new fields etc and
  /// write a migration
  static const int dbVersion = 2;

  final int version;

  const DbMigrationInfo._({
    required this.version,
    required UniqueId id,
  }) : super(id);

  factory DbMigrationInfo({
    required int version,
  }) =>
      DbMigrationInfo._(
        version: version,
        id: DbMigrationInfo.globalId,
      );

  static UniqueId globalId =
      const UniqueId.fromTrustedString('migration_info_id');
}
