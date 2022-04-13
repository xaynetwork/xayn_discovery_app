import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/db_entity.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';

part 'migration_info.freezed.dart';

@freezed
class MigrationInfo extends DbEntity with _$MigrationInfo {
  /// Increment this version for each change on the DB structure, new fields etc and
  /// write a migration
  static const int dbVersion = 1;

  factory MigrationInfo._({
    required int version,
    required UniqueId id,
  }) = _MigrationInfo;

  factory MigrationInfo({
    required int version,
  }) =>
      MigrationInfo._(
        version: version,
        id: MigrationInfo.globalId,
      );

  static UniqueId globalId =
      const UniqueId.fromTrustedString('migration_info_id');
}
