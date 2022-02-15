import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:hive_crdt/hive_crdt.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_settings.dart';
import 'package:xayn_discovery_app/domain/repository/reader_mode_settings_repository.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/base_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/reader_mode_settings_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/repository/hive_repository.dart';
import 'package:xayn_discovery_app/infrastructure/util/box_names.dart';

/// Hive's [ReaderModeSettings] repository implementation.
@LazySingleton(as: ReaderModeSettingsRepository)
class HiveReaderModeSettingsRepository
    extends HiveRepository<ReaderModeSettings>
    implements ReaderModeSettingsRepository {
  final ReaderModeSettingsMapper _mapper;
  Box<Record>? _box;

  HiveReaderModeSettingsRepository(this._mapper);

  @visibleForTesting
  HiveReaderModeSettingsRepository.test(this._mapper, this._box);

  @override
  BaseDbEntityMapper<ReaderModeSettings> get mapper => _mapper;

  @override
  Box<Record> get box => _box ??= Hive.box<Record>(BoxNames.readerModeSettings);

  @override
  ReaderModeSettings get settings =>
      getById(ReaderModeSettings.globalId) ?? ReaderModeSettings.initial();
}
