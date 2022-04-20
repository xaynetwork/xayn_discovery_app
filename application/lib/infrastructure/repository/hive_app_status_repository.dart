import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/app_status.dart';
import 'package:xayn_discovery_app/domain/model/extensions/hive_extension.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_status_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

/// Hive's [AppStatus] repository implementation.
@LazySingleton(as: AppStatusRepository)
class HiveAppStatusRepository extends HiveRepository<AppStatus>
    implements AppStatusRepository {
  final AppStatusMapper _mapper;
  Box<Record>? _box;

  HiveAppStatusRepository(this._mapper);

  @visibleForTesting
  HiveAppStatusRepository.test(this._mapper, this._box);

  @override
  BaseDbEntityMapper<AppStatus> get mapper => _mapper;

  @override
  Box<Record> get box => _box ??= Hive.safeBox<Record>(BoxNames.appStatus);

  @override
  AppStatus get appStatus {
    AppStatus? status = getById(AppStatus.globalId);
    if (status == null) {
      status = AppStatus.initial();
      // We need to save the initial status as it generates a random user ID.
      save(status);
    }
    return status;
  }
}
