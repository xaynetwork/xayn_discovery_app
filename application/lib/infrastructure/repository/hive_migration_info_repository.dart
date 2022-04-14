import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/repository/migration_info_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/migration_info_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/migrations/migration_info.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

/// Hive's [MigrationInfo] repository implementation.
@Singleton(as: MigrationInfoRepository)
class HiveMigrationInfoRepository extends HiveRepository<MigrationInfo>
    implements MigrationInfoRepository {
  final MigrationInfoMapper _mapper;
  Box<Record>? _box;

  HiveMigrationInfoRepository(this._mapper);

  @visibleForTesting
  HiveMigrationInfoRepository.test(this._mapper, this._box);

  @override
  BaseDbEntityMapper<MigrationInfo> get mapper => _mapper;

  @override
  Box<Record> get box => _box ??= Hive.box<Record>(BoxNames.migrationInfo);

  @override
  MigrationInfo? get migrationInfo => getById(MigrationInfo.globalId);
}
