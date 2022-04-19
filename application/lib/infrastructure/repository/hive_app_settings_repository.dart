import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/app_settings.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/domain/repository/app_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/app_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

/// Hive's [AppSettings] repository implementation.
@singleton
class HiveAppSettingsRepository extends HiveRepository<AppSettings>
    implements AppSettingsRepository {
  final AppSettingsMapper _mapper;
  Box<Record>? _box;

  HiveAppSettingsRepository(this._mapper);

  @visibleForTesting
  HiveAppSettingsRepository.test(this._mapper, this._box);

  @override
  BaseDbEntityMapper<AppSettings> get mapper => _mapper;

  @override
  Box<Record> get box => _box ??= Hive.box<Record>(BoxNames.appSettings);

  @override
  AppSettings get settings => getById(AppSettings.globalId)!;

  @override
  AppSettings? getById(UniqueId id) {
    return super.getById(id) ??
        (id == AppSettings.globalId ? AppSettings.initial() : null);
  }
}
