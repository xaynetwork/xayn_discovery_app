import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migration_info.dart';

class MigrationInfoMapper extends BaseMapper<MigrationInfo> {
  @override
  MigrationInfo? fromMap(Map? map) {
    if (map == null) return null;

    return MigrationInfo(
      version: map[_Fields.version] as int,
    );
  }

  @override
  Map toMap(MigrationInfo entity) {
    return {
      _Fields.version: entity.version,
    };
  }
}

class _Fields {
  static const int version = 0;
}
