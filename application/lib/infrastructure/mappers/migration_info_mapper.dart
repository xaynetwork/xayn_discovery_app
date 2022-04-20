import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migration_info.dart';

@lazySingleton
class MigrationInfoMapper extends BaseDbEntityMapper<DbMigrationInfo> {
  @override
  DbMigrationInfo? fromMap(Map? map) {
    if (map == null) return null;

    return DbMigrationInfo(
      version: map[_Fields.version] as int,
    );
  }

  @override
  DbEntityMap toMap(DbMigrationInfo entity) => {
        _Fields.version: entity.version,
      };
}

abstract class _Fields {
  static const int version = 0;
}
