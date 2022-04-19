import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'migration_info.freezed.dart';

@freezed
class DbMigrationInfo extends DbEntity with _$DbMigrationInfo {
  /// Increment this version for each change on the DB structure, new fields etc and
  /// write a migration
  static const int dbVersion = 1;

  factory DbMigrationInfo._({
    required int version,
    required UniqueId id,
  }) = _DbMigrationInfo;

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
