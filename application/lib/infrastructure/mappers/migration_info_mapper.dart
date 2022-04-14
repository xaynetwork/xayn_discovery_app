import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migration_info.dart';

@lazySingleton
class MigrationInfoMapper extends BaseDbEntityMapper<MigrationInfo> {
  @override
  MigrationInfo? fromMap(Map? map) {
    if (map == null) return null;

    return MigrationInfo(
      version: map[_Fields.version] as int,
    );
  }

  @override
  DbEntityMap toMap(MigrationInfo entity) => {
        _Fields.version: entity.version,
      };
}

abstract class _Fields {
  static const int version = 0;
}
